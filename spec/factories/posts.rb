FactoryBot.define do
  factory :post do
    title { "MyString" }
    slug { "MyString" }
    content { "MyText" }
    excerpt { "MyString" }
    featured_image_url { "MyString" }
    views_count { 1 }
  end
end
