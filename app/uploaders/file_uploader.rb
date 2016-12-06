class FileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "#{Rails.root}/uploads/#{model.class.to_s.underscore}/#{model.id}"
  end
end
