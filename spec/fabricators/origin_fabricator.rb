Fabricator(:origin, class_name: :'puffer_pages/origin') do
  name { sequence(:name) { |i| "origin_#{i}" } }
  host { 'http://localhost:3000' }
  token { SecureRandom.hex }
end
