# ミニSNSアプリ コードレビュー

レビュー日: 2026-06-23

対象:

- Backend: `D:\RubyProjects\backend`
- Frontend: `D:\RubyProjects\frontend`
- Rails / Reactの実装、DBスキーマ、認証、CI、テスト、README、画面スクリーンショット

## 結論

SNSに必要な主要機能をRails APIとReact SPAで一通り実装しており、未経験者の学習成果としては十分に技術力が伝わります。一方、現在のまま採用担当者へ提出すると、機能数よりも「テストとCIの不整合」「DB制約不足」「APIレスポンスの揺れ」「巨大なReactコンポーネント」が先に目につく状態です。

土台は悪くありません。新機能を増やすより、既存機能を壊さないテスト、認可、DB整合性、API契約、READMEを整える方が評価は大きく上がります。

## 採点

| 項目 | 評価 | コメント |
|---|---:|---|
| 総合評価 | 5.5 / 10 | 機能は豊富だが、提出品質として未整理な箇所が残る |
| バックエンド | 6.0 / 10 | Railsらしい関連と所有者スコープは良い。DB制約、API契約、request specが弱い |
| フロントエンド | 4.0 / 10 | UIは成立しているが、`App.jsx`への集中と状態・通信の混在が大きい |
| 設計 | 4.5 / 10 | API分離は良いが、未使用コード・不完全な機能・命名揺れがある |
| セキュリティ | 5.0 / 10 | 基本認証と所有権チェックはある。JWTログアウト、画像検証、CORS本番設定が不足 |
| 可読性・保守性 | 4.5 / 10 | RuboCopは通るが、設計上の責務分離とAPI統一が不足 |
| ポートフォリオとしての見栄え | 5.5 / 10 | X風UIは直感的。README、デモデータ、レスポンシブ、品質証明を強化したい |

## 評価されやすい強み

- Rails APIとReact SPAを別リポジトリに分離している
- Devise + JWTで認証付きAPIを構成している
- 投稿、コメント、いいね、フォロー、リポスト、画像アップロードまで実装している
- `current_user.posts.find`、`current_user.comments.find`によって他人の投稿・コメント削除を防いでいる
- フォローを自己参照の中間テーブルで表現している
- リポスト重複をDBの部分ユニークインデックスでも防ごうとしている
- `includes`、Kaminari、Active Storage、Brakeman、RuboCop、GitHub Actionsを導入している
- UIがSNSとして直感的で、スクリーンショットから機能を把握しやすい

## 弱く見える点

- CIがRSpecを実行しておらず、実際のテスト資産とCIが一致していない
- MinitestとRSpecが混在し、生成されたままの壊れたテストやpending specが残る
- `relationships`に外部キー、NOT NULL、重複防止インデックスがない
- `counter_cache`を指定しているのに、`users`テーブルに対応カラムがない
- `likes`はモデルで重複を防ぐだけで、DBの一意制約がない
- `App.jsx`が420行あり、画面、通信、認証、モーダル、フォームが一か所に集中している
- snake_caseとcamelCaseが混在し、フロント側が両方を吸収している
- READMEが途中で終わり、ER図、API表、セットアップ、テスト方法、公開URLがない
- 未使用の`Task`、`post_id`、`comment_id`、`LikesController#index`、`Login.jsx`などが残る

## バックエンドレビュー

### ルーティング

良い点:

- `/api`名前空間を使い、投稿・コメント・いいねをネストしている
- プロフィール更新を単数リソースにしている

問題:

- `posts#show`をルーティングしているが、コントローラに`show`がない
- `UsersController`の`index`、`show`、`update`、`destroy`はルーティングされていない
- `LikesController#index`はルーティングされず、内部でも未定義変数`comments`を参照する
- DeviseのHTML向けルートも含めて公開されているため、APIとして必要なルートを明示的に絞る余地がある
- コメント一覧だけ未ログインで取得可能で、投稿一覧はログイン必須という公開範囲の不整合がある

### コントローラ責務

`PostsController#create`のリポスト正規化は、今後複雑になるならモデルまたは専用オブジェクトへ移す候補です。ただし現状の規模でService Objectを大量導入する必要はありません。

先に行うべきことは以下です。

- 共通の404 / 422 / 401 JSONエラー形式を作る
- `show`などルートと実装の不一致をなくす
- 不要なアクションを削除する
- serializerへ渡す関連を明示的にpreloadする

### モデル・アソシエーション・DB

重大:

- `Relationship`は`counter_cache: :following_count`と`:followers_count`を指定するが、`users`テーブルに両カラムがない
- `relationships.follower_id`と`followed_id`に外部キー、NOT NULL、インデックス、一意制約がない
- 重複フォローおよびDB直接操作による自己フォローをDBで防げない
- `likes`に`[user_id, post_id]`のユニークインデックスがないため、同時リクエストでは重複し得る

整理対象:

- `comments.parent_id`は関連、外部キー、インデックスが不完全
- `likes.comment_id`はモデルで使われていない
- `posts.post_id`は`repost_id`導入後も残っている
- `tasks`テーブルと`Task`モデルはSNSに無関係
- `users.avatar_url`カラムとActive Storageの`avatar`が二重管理になっている
- `account_id`のモデル検証は大文字小文字を区別しないが、PostgreSQLの通常のunique indexは区別する

### バリデーション

投稿・コメント・account_idの基本検証はあります。追加候補:

- `username`と`bio`の最大長
- Relationshipの重複および自己フォロー防止
- Avatarのcontent typeとファイルサイズ
- repost先の存在と、リポスト対象のルール
- 空白文字だけの投稿・コメントの扱い

### N+1

`Post.includes(:user, :likes, :repost, comments: :user)`は意識できていますが、serializer内でN+1が再発しています。

- 投稿ごとの`user.following_count`と`followers_count`が毎回COUNTを発行する
- 投稿ユーザーごとの`current_user.following?(user)`がクエリを発行し得る
- `repost.user`をpreloadしていない
- フォロー一覧でもユーザーごとにフォロー判定と件数取得が走る

件数は正しいcounter cacheを用意するか、一覧用途では不要な情報を返さない設計にするべきです。

### Serializer / JSON

独自serializerで必要項目を限定している点は良いです。ただし以下が保守性を下げています。

- `createdAt`、`avatarUrl`、`account_id`、`following_count`が混在
- Userの表現が各serializer内で重複
- 登録時だけActiveRecordオブジェクトをそのまま返している
- 一覧にページネーション情報がない
- フロントが期待する`isRepostedByMe`を返していない
- コメントのレスポンス形が一覧場所によって異なる

APIの命名規則をcamelCaseまたはsnake_caseのどちらかに統一し、User要約表現を共通化してください。

### 認証・認可・current_user

良い点:

- 作成系と削除系で`authenticate_user!`を使用
- 投稿・コメント削除を`current_user`の関連から検索している
- プロフィール更新対象を`current_user`に固定している
- いいね解除も現在ユーザーのLikeだけを対象にしている

改善点:

- フロントのログアウトがAPIの`DELETE /users/sign_out`を呼ばないため、JWTはサーバー側で失効せず期限まで利用可能
- 登録直後のJWT発行経路がDevise JWTのdispatch設定と一致していない可能性が高い
- 認証失敗、RecordNotFound、validation errorのJSON形式を統一する
- 今後権限が増えるまではPundit導入は必須ではない。所有者スコープをrequest specで証明する方が先

### API設計

RESTに近いものの、API契約としては未完成です。

- フォロー作成は`POST /relationships`、解除は`DELETE /relationships/:user_id`で、`:id`がRelationship IDではなくUser IDになっている
- `POST /users`で登録するDeviseルートと`/api`配下が混在する
- 一覧のpagination metadataがない
- 204、200、201、422の使い分けは概ね妥当だが、存在しないLike削除で204を返す設計は明文化したい

## フロントエンドレビュー

### コンポーネント設計

最大の課題です。`App.jsx`に以下が集中しています。

- 認証画面
- レイアウト
- 投稿一覧
- 投稿カード
- コメント
- フォロー一覧モーダル
- プロフィール表示・編集
- 全API通信
- localStorage同期

さらに`PostItem`と`UserListModal`を`App`関数内で定義しているため、親の再レンダー時にコンポーネント型が再生成され、子のローカルstateが意図せず初期化される可能性があります。

最初は以下の単位で分割すれば十分です。

- `features/auth/AuthForm`
- `features/posts/PostList`, `PostItem`, `PostForm`
- `features/profile/ProfileView`, `ProfileEditForm`
- `features/relationships/UserListModal`
- `components/layout/AppLayout`, `Sidebar`

### hooks・state管理

- `useEffect`に`fetchPosts`の依存がなく、ESLint警告が出ている
- localStorageとReact stateが二重の正本になっている
- ログインユーザーIDを「自分の投稿を一覧から探す」ことで得ており、投稿が0件だとフォロー一覧を開けない
- 投稿取得からプロフィール情報も推測しており、責務が混ざっている
- 現規模ならReduxは不要。`AuthContext`と機能別custom hookで十分

`GET /api/me`相当のエンドポイントを用意し、ログインユーザー情報を一度取得する設計が自然です。

### API通信

- `App.jsx`内のAxios、`client.js`、`posts.js`が重複している
- API URLが複数箇所にハードコードされている
- 401時の共通ログアウト処理がない
- エラーの多くが`alert`または`console.error`だけ
- mutation後に毎回一覧全取得しており、規模が増えると遅くなる

まずAPI clientを一つに統一し、base URLを`VITE_API_BASE_URL`へ移してください。React Query導入は、その後でも遅くありません。

### フォーム・ローディング・エラー

- 投稿送信中、認証中、プロフィール保存中のloading stateがない
- 二重送信を防げない
- `MAX_CHARS`は未使用で、投稿欄に`maxLength`や残文字表示がない
- サーバーのvalidation errorを利用者へ具体的に表示しない
- inputに`required`、label、autocompleteが不足
- 画像プレビューのObject URLをrevokeしていない

### Tailwind / UI・UX

良い点:

- X風の視覚構造が分かりやすい
- 色、余白、ボーダー、モーダルに統一感がある
- 主要操作が画面から理解しやすい

改善点:

- 画面幅が狭い場合のサイドバー・本文レイアウトが未対応
- ローディング、空状態、エラー状態、成功通知が弱い
- モーダルに`role="dialog"`、フォーカストラップ、Escapeキー対応がない
- アイコンだけのボタンに`aria-label`がない
- テスト投稿「あ」が並ぶスクリーンショットは完成度を低く見せる
- 本番デモ用に、複数ユーザーと自然な投稿を用意すると印象が大きく改善する

### TypeScript

TypeScript化は評価向上に有効ですが、最優先ではありません。先にAPIレスポンスを統一し、コンポーネントを分割してから段階的に導入してください。

型を付ける価値が高い対象:

- `UserSummary`
- `Post`
- `Comment`
- `AuthResponse`
- API error
- コンポーネントprops

## セキュリティレビュー

### 現在守れていること

- 投稿・コメント・プロフィールの変更対象は概ね`current_user`に固定されている
- Strong Parametersを使用している
- JWTに1日の有効期限を設定している
- productionでSSLを強制している
- パスワード、token等をログフィルタ対象にしている
- Brakemanの通常スキャンでは未無視の警告は0件

### 公開前に直すべきこと

1. フロントのログアウト時にDeviseのsign_out APIを呼び、JTIを更新する
2. RelationshipとLikeへDB一意制約・外部キー・NOT NULLを追加する
3. Active Storage画像へファイルサイズ・content type制限を追加する
4. CORS originを環境変数化し、本番フロントURLのみ許可する
5. 登録・ログイン・認証エラーをrequest specで確認する
6. `config/brakeman.ignore`の各無視理由を書くか、不要な無視を削除する

### JWT保存場所

localStorageは実装が簡単ですが、XSSが成立した場合にtokenを読み取られます。Reactの通常描画は文字列をescapeするため即座に脆弱という意味ではありませんが、第三者スクリプトや将来のHTML挿入には注意が必要です。

ポートフォリオでは以下のどちらかをREADMEに明記すると良いです。

- 現状はBearer JWT + localStorage。短い有効期限、CSP、依存管理、XSS対策を前提とする
- 将来はHttpOnly / Secure / SameSite Cookie方式を検討し、CSRF対策とセットで設計する

### CSRF

Authorization headerで送るBearer token方式で、ブラウザが自動送信するCookie認証を使わない限り、通常のCSRFリスクは低いです。一方、HttpOnly Cookieへ移行するならCSRF tokenまたはSameSite設計が必要です。

### 画像

`accept="image/*"`はブラウザ側の補助にすぎず、API直接送信を防げません。サーバーで以下を検証してください。

- MIME type
- ファイルサイズ
- 必要なら画像としてdecode可能か
- 本番ストレージの永続性
- 表示時のContent-DispositionとContent-Type

## 検証結果

| コマンド | 結果 |
|---|---|
| `bundle exec rubocop` | 70 files、違反0 |
| `bundle exec brakeman --no-pager` | 未無視警告0、無視警告2 |
| `bundle exec rspec` | 12 examples、0 failures、1 pending |
| `npm.cmd run lint` | 7 errors、1 warning |
| `bundle exec rails test` | Minitest / Rails間の引数エラーで失敗 |

補足:

- 最初のRSpec実行時はtest DBに未反映migrationが6件あり停止した
- CIはRSpecではなくMinitestを実行している
- フロントエンドにはテストとCIがない

## ポートフォリオ提出可否

現状でも「開発経験を説明する題材」にはなりますが、書類上の代表作品として公開するなら、少なくとも以下を終えてからが安全です。

- DB制約とRelationship不整合の修正
- 認証・認可request spec
- CIでRSpecとフロントlint/buildを実行
- `App.jsx`の第一段階分割
- README完成
- 公開URLまたは短いデモ動画

この5点を整えれば、未経験者ポートフォリオとして「機能を作った」から「品質を考えて改善できる」へ評価軸を移せます。
