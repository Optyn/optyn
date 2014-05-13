require 'nokogiri'
require 'messagecenter/templates/markup_generator'
require 'messagecenter/templates/existing_template'
require 'messagecenter/templates/blank_template'
require 'messagecenter/templates/system_template_personalizer'
require 'messagecenter/templates/structure_creator'
require 'iconv'


class Template < ActiveRecord::Base
  include UuidFinder
  include Messagecenter::Templates::SystemTemplatePersonalizer
  include Messagecenter::Templates::StructureCreator
  include ShopLogo
  include Rails.application.routes.url_helpers
  include ERB::Util
  include ActionView::Helpers::OutputSafetyHelper

  attr_accessor :parsed_html, :parsed_result, :pared_extends, :styles

  attr_accessible :title,:logo, :shop_id, :system_generated, :name, :structure, :html

  serialize :structure, Hash

  has_many :messages #, dependent: :destroy
  has_many :stylesheets
  has_one :template_upload #, dependent: :destroy
  belongs_to :shop
  has_one :template_image, dependent: :destroy

  after_create :assign_uuid, :create_structure

  after_save :thumbnail_generator, if: :html_changed?

  acts_as_paranoid({column: 'deleted_at', column_type: 'time'})

  scope :fetch_system_generated, where(system_generated: true)

  scope :for_shop, ->(shop_identifier) { where(shop_id: shop_identifier) }

  scope :for_name, ->(template_name) { where(name: template_name) }

  scope :priority_position, order(:position)

  PLACE_HOLDER_ELEM = "<placeholder></placeholder>\n"
  FB_PLACE_HOLDER_ELEM = "<fbplaceholder></fbplaceholder>"
  TW_PLACE_HOLDER_ELEM = "<twplaceholder></twplaceholder>"

  LAYOUT_BACKGROUND_COLOR = '#d4d4d4'
  HEADER_FONT_FAMILIES = [%{'Helvetica Neue', Helvetica, Arial, sans-serif}, %{Verdana, Arial, sans-serif}, %{'Courier New', Courier, Arial, sans-serif}]
  HEADER_BACKGROUND_COLOR = Shop::DEFAULT_HEADER_BACKGROUND_COLOR
  CONTENT_BACKGROUND_COLOR = '#FFFFFF'
  SIDEBAR_BACKGROUND_COLOR = '#C9C9C9'
  CONTENT_TITLE_COLOR = '#000000'
  CONTENT_PARAGRAPH_COLOR = '#000000'
  CONTENT_LINK_COLOR = '#000000'
  CONTENT_BUTTON_COLOR = '#FFFFFF'
  CONTENT_BUTTON_BACKGROUND_COLOR = '#64aaef'
  FOOTER_BACKGROUND_COLOR = Shop::DEFAULT_HEADER_BACKGROUND_COLOR 
  FOOTER_PARAGRAPH_COLOR = '#000000'
  FOOTER_LINK_COLOR = '#2ba6cb' 

  OPTYN_SPACE_PLACEHOLDER = "--insert--optyn-space--"

  mount_uploader :thumbnail, TemplateThumbnailUploader

  def self.with_default_settable_properties(template_id, shop)
   existing_template = Template.find(template_id) 
   update_settable_properties(template_id, shop, existing_template.default_selectable_properties(shop)) 
  end

  def self.update_settable_properties(template_id, shop, selectable_properties)
    existing_template = Template.find(template_id)
    new_template = Template.new(html: existing_template.html, shop_id: shop.id)
    new_template.add_markup_classes
    new_template.convert_system_template(selectable_properties)
    new_template.replace_custom_tags
    new_template.html
  end

  def show_image?
    template_image.present?    
  end

  def image_location
    if show_image?
      template_image.image.url
    end
  end


  def self.system_generated
    fetch_system_generated.priority_position
  end

  def self.basic
    for_name("Basic").first
  end

  def self.copy(template_id, name, shop, settable_properties)
    existing_template = Template.find(template_id)
    new_template = Template.new(html: existing_template.html, name: name, shop_id: shop.id)
    new_template.add_markup_classes
    new_template.convert_system_template(settable_properties)
    new_template.save
    new_template.id
  end


  def personalize_body(content, message, receiver)
    # Sanitaize the footer
    template_node = Nokogiri::HTML(content)
    template_node.css('.optyn-footer').each do |footer_node|

      #substitute the receiver email
      footer_node.css('.optyn-receiver-email').each do |receiver_email_node|
        receiver_email_node.swap(receiver.email)
      end

      #substitute the unsubscribe link
      footer_node.css('.optyn-unsubscribe').each do |unsubscribe_node|
        unsubscribe_node.swap(%{<a href="#{SiteConfig.email_app_base_url}#{SiteConfig.simple_delivery.unsubscribe_path}/#{Encryptor.encrypt(receiver.email, message.uuid)}?tracker=#{receiver.uuid}">Unsubscribe</a>})
      end
    end

    body_node = template_node.css('body').first
    body_node.add_child(%{<img src="#{SiteConfig.email_app_base_url}#{SiteConfig.simple_delivery.open_path}/#{receiver.encode64_uuid}?tracker=#{receiver.uuid}" style="width: 1px; height: 1px;", alt="" />})

    template_node.to_s
  end

  def fetch_editable_content(message)
    content = ""

    content = Messagecenter::Templates::MarkupGenerator.generate_editable_content(message, self)
    content = content.gsub(OPTYN_SPACE_PLACEHOLDER, "&nbsp;")

    content
  end

  def fetch_content(message)
    content = ""

    html = Messagecenter::Templates::MarkupGenerator.generate_content(message, self)
    premailer = Premailer.new(html, with_html_string: true)
    content = premailer.to_inline_css
    content = content.encode("UTF-8", "binary", :invalid => :replace, :undef => :replace, replace: "")
    content = content.gsub(OPTYN_SPACE_PLACEHOLDER, "&nbsp;")
    content = content.to_s.squish
    content = content.gsub(/<\/td>\s?<td/ixm, "</td><td")
    content
  end

  def fetch_cached_content(message, force=false)
    Rails.cache.fetch("template_message_#{message.uuid}", force: false, expires_in: SiteConfig.ttls.email_footer) do
      fetch_content(message)
    end
  end

  def delete_cached_content(message_uuid)
    Rails.cache.delete("template_message_#{message_uuid}")
  end

  def thumbnail_generator
    ThumbnailGenerationWorker.perform_async(self.id)
  end

  def self.generate_thumbnail(template_id)
    template = Template.find(template_id)
    template.remove_thumbnail! if !template.thumbnail.to_s.blank?
    file = html_to_thumbnail(template)
    template.thumbnail = file
    template.save
    file.unlink
  end

  def process_urls(content, message, receiver)
    user_info_token = Encryptor.encrypt_for_template({:message_id => message.id, :email => receiver.email, :manager_id => message.manager_id})
    optyn_url = "#{SiteConfig.email_app_base_url}#{SiteConfig.simple_delivery.link_path}?uit=#{user_info_token}"
    body = Nokogiri::HTML(content)

    #replace urls in a tags
    body.css('.optyn-introduction a, .optyn-content a').each do |link|
      original_href = link['href']
      link['href'] = "#{optyn_url}&redirect_url=#{original_href}"
    end
    return body.to_s
  rescue Exception => e
    Rails.logger.info '-!'*80
    Rails.logger.info 'Error in processing urls in message with id: ' + message.id.to_s
    Rails.logger.error e
    return content
  end

  def process_content(content, receiver)
    content.gsub(/{{Customer Name}}/i, "#{receiver.first_name.capitalize if receiver.first_name}")
  end

  private
  def self.html_to_thumbnail(template)
    file = Tempfile.new(["template_#{template.id.to_s}", 'jpg'], 'tmp', :encoding => 'ascii-8bit')
    file.write(IMGKit.new(template.html, quality: 50).to_jpg)
    file.flush
    file
  end

  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
    self.save(validate: false)
  end
end
