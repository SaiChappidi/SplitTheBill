module ApplicationHelper
  AVATAR_HUES = 8

  def avatar_tag(user, size: nil)
    initials = user.name.split.map { |part| part[0] }.join[0, 2]
    hue = user.id % AVATAR_HUES
    classes = [ "avatar", "avatar-hue-#{hue}" ]
    classes << "avatar-lg" if size == :lg
    content_tag(:span, initials, class: classes.join(" "), title: user.name)
  end

  def category_tag(category)
    content_tag(:span, category, class: "tag tag-#{category.downcase}")
  end

  def money(amount)
    "$#{format('%.2f', amount.to_f)}"
  end
end
