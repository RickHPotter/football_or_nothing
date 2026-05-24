# frozen_string_literal: true

module ApplicationHelper
  def game_nav_link(label, path)
    active = current_page?(path)
    link_to label, path, class: class_names("game-nav-link", "is-active": active), aria: active ? { current: "page" } : nil
  end

  def status_badge(label, tone: nil)
    tag.span label, class: class_names("badge", "badge-good": tone == :good, "badge-warn": tone == :warn)
  end

  def panel(title, badge: nil, &)
    render "shared/panel", title:, badge:, body: capture(&)
  end
end
