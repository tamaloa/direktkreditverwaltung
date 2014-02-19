
class PdfInterestThanks < Prawn::Document
  include PdfHelper

  COLUMN_SPACER = 90
  IMAGE_WITH = 150

  def initialize(contracts, year, view)
    super(page_size: 'A4', page_layout: :landscape, top_margin: 35)
    @contracts = contracts
    @year = year
    @view = view
    hash = YAML.load_file("#{Rails.root}/custom/text_snippets.yml")
    texts = HashWithIndifferentAccess.new(hash)

    font 'Times-Roman'
    fill_color '444444'

    index = 0
    y = cursor
    width = bounds.width + 65
    @contracts.each do |contract|
      interest, _ = contract.interest @year
      next if interest == 0
      if index%2 == 0 && index != 0
        start_new_page
      end

      bounding_box [width/2.0 * (index%2), y], 
                   width: (width/2.0 - COLUMN_SPACER) do
        image "#{Rails.root}/custom/logo.png", at: [width/2.0-IMAGE_WITH - 70, cursor], width: IMAGE_WITH
        move_down 30 
        text "Hallo #{contract.contact.try(:prename)},", size: 14, style: :bold_italic
        move_down 10 
        text texts['thanks_what_happened'], style: :italic
        move_down 10
        text texts['next_year'], style: :italic
        move_down 10 
        text texts['invitation'], style: :italic
        move_down 10 
        text texts['wish'], style: :italic
        move_down 10 
        image "#{Rails.root}/custom/image.png", at: [0, cursor], width: IMAGE_WITH
        move_down 10
        bounding_box [IMAGE_WITH + 20, cursor], width: (width/2.0 - COLUMN_SPACER - IMAGE_WITH - 20) do
          text texts['greetings'], style: :italic
        end
      end

      index += 1
    end
  end
end
