module FlashHelper
  def flash_klass(type)
    case type
    when "notice" then "success"
    when "alert" then "danger"
    end
  end
end
