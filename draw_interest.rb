require 'RMagick'
require "YAML"

include Magick

# INITIALIZE ALL

$MARGIN = [130,130,130,130] #LEFT, TOP, RIGHT, BOTTOM
$BORN_YEAR = 1992

$Titles = ["生活轨迹", "技能", "介绍"] 
#TODO:$Titles = read_title("data.csv")
#TODO:$Descriptions = read_description("data.csv")

class Event
  attr_accessor :name, :start_year, :end_year, :extent, :place
  def initialize(name, start_year, end_year, extent, place)
    @name = name
    @start_year = start_year
    @end_year = end_year
    @extent = extent
    @place = place
  end
end

# In case you use year as your fisrt part

def convert_year_to_x_point(year)
   step = 1494 / (2014 - $BORN_YEAR + 1) 
   return xp =  180 + step * (year - BORN_YEAR)
end

def convert_semester_to_x_point(semester)
   step = 1574 / 9 
   return xp =  180 + step * semester 
end

def decide_color(event)
  case event.place
    when 1 then
      "orange"
    when 2 then
      "orange1"
    when 3 then
      "orange2"
    when 4 then
      "orange3"
    when 5 then
      "orange4"
    when 6 then
      "sienna"
    when 7 then
      "sienna1"
    end
end

$config = YAML.load(File.open("config/config.yml").read)
events = YAML.load(File.open("events.yml").read) 

# events << Event.new("班长", 2, 5, 1, 7)

# Create the canvas to draw on

canvas = ImageList.new
canvas.new_image(1754, 2480) {
  self.background_color = 'black'
}

# Draw Titles 

title = Draw.new
title.fill('white')
title.stroke('transparent')
title.pointsize(30)
# title.font("BS.ttf") 
title.font($config["fonts"][3]) 
title.font_weight("bold")
title.font_style(ItalicStyle)
title.text(130,130,$Titles[0])
title.draw(canvas)

# Draw axes

axes = Draw.new
axes.fill_opacity(0)
axes.stroke('#aaa')
axes.stroke_width(1)
axes.stroke_linecap('round')
axes.stroke_linejoin('round')
axes.polyline(130,700, 130 + 1494,700)
axes.draw(canvas)

# Draw Lables
lables = Draw.new
lables.font_weight(NormalWeight)
lables.fill('#aaa')
lables.stroke('transparent')
lables.font_style(ItalicStyle)
lables.pointsize(20)

# Uncomment this if you use year

#year = $BORN_YEAR
#while year <= 2014 do
#  xp = convert_year_to_x_point(year)
#  lables.polyline(xp ,700, xp, 700 - 10 )
#  if year%2 == 0
#    lables.annotate(canvas, 0, 0, xp ,700 + 15 , year.to_s) {
#      self.font = $config["fonts"][0]
#      self.rotation = 45
#      self.fill = 'white'
#      self.stroke = 'transparent'
#      self.pointsize = 16 
#    }
#  end
#  year = year + 1
#end

# If you use semester
#
semester = 0 
count = 0
while semester <= 8 do
  xp = convert_semester_to_x_point(semester)
  lables.polyline(xp ,700, xp, 700 - 10 )
  if count%4 == 0
    lables.annotate(canvas, 0, 0, xp ,700 + 15 , "#{count/4+2010}.9") {
      self.font = $config["fonts"][0]
      self.rotation = 45
      self.fill = '#aaa'
      self.stroke = 'transparent'
      self.pointsize = 16 
    }
  elsif count%4 == 2
    lables.annotate(canvas, 0, 0, xp ,700 + 15 , "#{(count+2)/4+2010}.3") {
      self.font = $config["fonts"][0]
      self.rotation = 45
      self.fill = '#aaa'
      self.stroke = 'transparent'
      self.pointsize = 16 
    }
  end
  semester = semester + 0.5
  count = count + 1 
end

lables.draw(canvas)

# Draw Event 

draw_events = Draw.new

puts "Drawing event... "
for event in events do
  # Parameters
 
  # xp = convert_year_to_x_point(event.start_year) 
  # xp_end = convert_year_to_x_point(event.end_year) 
    xp = convert_semester_to_x_point(event.start_year)
    xp_end = convert_semester_to_x_point(event.end_year)

    # Draw background
    draw_events.stroke(decide_color(event))
    draw_events.stroke_width(24)
    draw_events.stroke_opacity(0.70)
    draw_events.fill("transparent")
    draw_events.fill_opacity(0)
    draw_events.line(xp+1,410+35*event.place,xp_end,410+35*event.place)

    # Draw start line
    draw_events.stroke_width(1) 
    draw_events.stroke_dasharray(4,2)
    draw_events.line(xp,700,xp,400)
    # Draw end line
    draw_events.line(xp_end+1,700,xp_end+1,400)

    # Draw ellipse
    draw_events.stroke_width(0) 
    draw_events.stroke("transparent")
    draw_events.stroke_opacity(0)
    draw_events.stroke_dasharray()
    draw_events.fill(decide_color(event))
    draw_events.fill_opacity(0.80)
    r_long = xp_end - xp
    draw_events.ellipse((xp + xp_end)/2, 400, r_long/2, event.extent*40, 180, 0 )

    # Adding text
    draw_events.annotate(canvas, 0, 0, xp+10 , 419+35*event.place , event.name) {
      draw_events.stroke = "none" 
      draw_events.font = $config["fonts"][3] 
      draw_events.fill = "white" 
      draw_events.pointsize = 20 
    }
end
draw_events.draw(canvas)

# All in All
canvas.write("CV_interest.jpg")
# exec 'open ./CV_interest.jpg'

