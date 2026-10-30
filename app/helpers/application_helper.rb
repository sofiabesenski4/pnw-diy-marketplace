module ApplicationHelper
  # Product images render inside cached fragments, but S3 presigned URLs
  # expire after a few minutes. The Rails representation route is stable and
  # redirects to a freshly signed URL on every request.
  def product_image_path(image, style)
    url_for(image.attachment.variant(style))
  rescue ActiveStorage::FileNotFoundError
    image.url(style)
  end
end
