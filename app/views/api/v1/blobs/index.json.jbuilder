json.array! @blobs do |blob|
  json.id blob.id
  json.data blob.data
  json.size blob.size
  json.created_at blob.created_at.iso8601
end