class FileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "#{Rails.root}/uploads/#{model.id}"
  end
end
