# ミニSNSアプリ 改善計画

方針:

- 新機能追加より既存機能の安全性と説明可能性を優先する
- 一度に大きく書き換えず、小さなPR単位で進める
- 各変更にテストを付け、変更前後の挙動を明確にする
- Service Objectや状態管理ライブラリを目的なく増やさない

## 最優先で直すべき問題

### 1. RelationshipのDB・モデル不整合

理由:

`counter_cache`対象カラムがなく、フォロー作成が例外になる可能性があります。また外部キー、一意制約、NOT NULLがなく、データ破損を防げません。

修正案:

- `users.following_count`、`users.followers_count`を追加するか、counter cache指定を外す
- `relationships`をbigint参照へ統一
- follower / followedへNOT NULL、外部キー、indexを追加
- `[follower_id, followed_id]`へunique indexを追加
- 自己フォローをモデルで拒否する
- follow / unfollowのmodel specとrequest specを追加

### 2. CIとテスト体系の統一

理由:

READMEはRSpecを掲げていますが、CIはMinitestだけを実行しています。品質を示すCIが実際のテストを検証していません。

修正案:

- RSpecへ統一し、不要な`test/`を削除
- CIを`bundle exec rspec`へ変更
- frontendにlintとbuildのCIを追加
- 認証・認可・主要APIのrequest specを追加

### 3. DB一意制約・不要カラムの整理

理由:

モデルvalidationだけでは同時リクエストを完全に防げません。未使用カラムは設計意図を曖昧にします。

修正案:

- likes `[user_id, post_id]` unique index
- account_idをDBでも大文字小文字非依存にする
- `posts.post_id`、`likes.comment_id`、`tasks`を利用していないなら削除
- commentsの階層化を残すなら`parent`関連とFKを完成させ、使わないなら`parent_id`を削除

### 4. JWTログアウトと認証フロー

理由:

現在のフロントログアウトはlocalStorageを消すだけで、発行済みJWTをサーバー側で失効しません。

修正案:

- `DELETE /users/sign_out`を呼んだ後にlocal stateを破棄
- 401 response interceptorでセッションを終了
- sign up直後にtokenを発行するか、登録後ログイン画面へ戻すかを統一
- request specでログイン、保護API、ログアウト後token無効化を確認

### 5. APIの壊れた・未使用箇所を整理

理由:

ルートと実装の不一致は、面接官が数分コードを見ただけでも発見しやすい品質問題です。

修正案:

- `posts#show`を実装するかrouteを削除
- `LikesController#index`を削除
- 未使用のUsersControllerアクションを削除するかrouteを追加
- JSON error responseを統一

## できれば直した方がいい問題

### 6. SerializerとAPI命名の統一

- camelCaseまたはsnake_caseへ統一
- User要約serializerを共通化
- raw modelを返さない
- `isRepostedByMe`、件数、pagination metadataを仕様化
- APIレスポンス例をREADMEへ掲載

### 7. N+1の解消

- `repost: :user`をpreload
- 一覧で不要なfollow件数を返さない
- current_userのfollowing IDsを一度だけ取得して判定
- Bullet導入は開発時の検出補助として有効

### 8. フロントAPI clientの一本化

- `VITE_API_BASE_URL`を利用
- requestでAuthorization付与
- responseで401を共通処理
- API errorを共通形式へ変換
- `App.jsx`内の独自Axiosと未使用clientを統合

### 9. Reactコンポーネント分割

第一段階:

- `AuthForm`
- `Sidebar`
- `PostForm`
- `PostList`
- `PostItem`
- `ProfileView`
- `ProfileEditForm`
- `UserListModal`

第二段階:

- `useAuth`
- `usePosts`
- `useProfile`
- `useRelationships`

### 10. ローディング・エラー・フォーム

- submit中のbutton disable
- loading skeletonまたはspinner
- inline validation message
- toast通知
- 140文字制限と残文字表示
- 空白のみの送信防止

## ポートフォリオ評価を上げる改善

### 11. READMEの完成

- 公開URL
- デモアカウント
- GIFまたは短い動画
- ER図
- API表
- セキュリティ判断
- テスト戦略
- 改善前後の説明

### 12. request specをアピール材料にする

最低限のシナリオ:

- 未ログインでは投稿作成不可
- 他人の投稿・コメントを削除不可
- 自分の投稿・コメントは削除可能
- 同一投稿へ重複いいね不可
- 重複フォロー・自己フォロー不可
- logout後tokenは利用不可
- 不正な画像は拒否

### 13. デモ品質

- 自然なサンプル投稿
- 3〜5人のユーザー
- いいね、フォロー、リプライ、リポストが一画面で分かる状態
- モバイルスクリーンショット
- ローディング・空状態のスクリーンショット

### 14. 改善履歴

「最初は動作優先で単一コンポーネントに実装し、その後、テストで保護しながら機能別に分割した」という履歴は、未経験者のポートフォリオで非常に説明しやすい題材です。

## 余裕があればやる改善

- TypeScriptをAPI型から段階導入
- React Router導入
- TanStack Query導入
- OpenAPI定義
- Docker ComposeでRails / PostgreSQL / frontendを一括起動
- 画像をS3互換ストレージへ保存
- ページネーションまたは無限スクロール
- rate limit
- CSPやセキュリティヘッダー
- system test / E2E testを主要導線に1〜2本

## 今は無理にやらなくていい改善

- マイクロサービス化
- GraphQL化
- Redux導入
- Repositoryパターン
- 全処理のService Object化
- Kubernetes
- WebSocket通知
- 大規模なデザイン刷新

理由:

現状の評価を下げているのは高度な技術の不足ではなく、既存機能の整合性・テスト・説明不足です。複雑な技術を増やすより、今ある設計を堅くする方が実務的です。

## 推奨する実施順

### PR 1: テスト基盤の正常化

- RSpecへ統一
- CIでRSpecを実行
- frontend lintエラーを解消
- 既存挙動をrequest specで固定

### PR 2: RelationshipとLikeの整合性

- migration
- validation
- model / request spec

### PR 3: 認証フロー

- sign up仕様統一
- logout API
- 401共通処理
- 認証request spec

### PR 4: API契約

- JSON命名統一
- serializer共通化
- error format
- pagination metadata

### PR 5: React第一段階分割

- 見た目と挙動を変えずにファイル分割
- API client一本化
- loading / error state追加

### PR 6: README・デモ

- README完成
- ER図、API表、スクリーンショット
- デモデータ
- 公開URL

## 最初の小さな改修単位

最初は「Relationshipを直す」前に、フォローAPIのrequest specを追加してください。そのテストを赤くし、migrationとモデル修正で緑にする流れが安全です。

対象:

- `spec/requests/api/relationships_spec.rb`
- `app/models/relationship.rb`
- `app/models/user.rb`
- 新規migration

確認項目:

- フォロー成功
- 重複フォロー拒否
- 自己フォロー拒否
- 未ログイン拒否
- フォロー解除成功
- DB制約で重複を拒否

これが最も「壊れた可能性がある重要機能」を「実務的なテスト付き改善」に変えやすい着手点です。
