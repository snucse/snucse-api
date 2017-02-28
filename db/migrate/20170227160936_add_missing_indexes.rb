class AddMissingIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :tag_relations, :related_tag_id
    add_index :tag_relations, :writer_id
    add_index :activities, :actor_id
    add_index :activities, :profile_id
    add_index :activities, :article_id
    add_index :favorite_articles, [:article_id, :user_id]
    add_index :favorite_articles, :article_id
    add_index :profiles, :admin_id
    add_index :api_keys, :user_id
    add_index :articles, :writer_id
    add_index :articles_profiles, [:article_id, :profile_id]
    add_index :articles_profiles, :profile_id
    add_index :articles_profiles, :article_id
    add_index :comments, :writer_id
    add_index :comments, :article_id
    add_index :comments, :parent_comment_id
    add_index :article_tags, :article_id
    add_index :article_tags, :tag_id
    add_index :article_tags, :writer_id
    add_index :attachments, :uploader_id
    add_index :attachments, :article_id
    add_index :contacts, :user_id
    add_index :contacts, :contact_id
    add_index :follows, :profile_id
    add_index :image_tags, :attachment_id
    add_index :image_tags, :tag_id
    add_index :image_tags, :writer_id
    add_index :messages, :sender_id
    add_index :messages, :receiver_id
    add_index :profile_comments, :writer_id
    add_index :profile_comments, :profile_id
    add_index :profile_comments, :parent_comment_id
    add_index :profile_tags, :profile_id
    add_index :profile_tags, :tag_id
    add_index :profile_tags, :writer_id
    add_index :recommendation_counts, :article_id
    add_index :surveys, :creator_id
    add_index :surveys, :article_id
    add_index :tags, :creator_id
    add_index :votes, :survey_id
    add_index :votes, :voter_id
  end
end
