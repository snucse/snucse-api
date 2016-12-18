class FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "#{Rails.root}/uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :thumb, if: :image? do
    process resize_to_fill: [120, 120]
  end

protected

  def image?(new_file)
    new_file.content_type.start_with? "image"
  end
end
