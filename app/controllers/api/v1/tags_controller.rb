class Api::V1::TagsController < Api::V1::ApiController
  api! "태그의 정보를 전달한다."
  example <<-EOS
  {
    "creator": {
      "id": 1,
      "username": "writer",
      "name": "작성자",
      "profileImageUri": "http://placehold.it/100x100"
    },
    "articles": [
      {"id": 1, "title": "title", ...},
      ...
    ],
    "profiles": [
      {"id": 1, "name": "13학번 모임", ...},
      ...
    ]
  }
  EOS
  def show
    @tag = Tag.find_by_name! params[:tag]
  end
end
