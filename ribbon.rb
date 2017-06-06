require 'set'

module Colours
  SPACE_BLACK   = [  26,  39,  50]
  CHARCOAL_GREY = [  68,  79,  81]
  COOL_GREY     = [ 112, 138, 144]
  SILVER        = [ 198, 199, 201]
  WHITE         = [ 255, 255, 255]
  BLOOD_RED     = [ 117,  38,  61]
  CRIMSON       = [ 175,  30,  45]
  SCARLET       = [ 232,  17,  45]
  ORANGE        = [ 246, 126,   0]
  GOLD          = [ 173, 155,  12]
  YELLOW        = [ 252, 209,  22]
  EMERALD       = [   0, 183,  96]
  FOREST_GREEN  = [   0, 122,  61]
  EMERALD_GREEN = [   0, 183,  96]
  DARK_GREEN    = [  35,  79,  51]
  NAVY_BLUE     = [  17,  33,  81]
  ROYAL_BLUE    = [ 102,  86, 188]
  LIGHT_BLUE    = [ 155, 196, 226]
  PURPLE        = [ 112,  53, 114]
  ROSE          = [ 211, 107, 158]
  VIOLET        = [  86,   0, 140]
  KELLY_GREEN   = [  76, 187,  23]
  TURQUOISE     = [   0, 140, 130]
  JADE          = [   0, 178, 122]
  RUBY          = [ 229,   5,  58]
  SAPPHIRE      = [ 17,   34, 175]
  BRONZE        = [ 128,  64,  32]
end
module Metals
  GOLD          = "#decd87"
  BRONZE        = "#a05a2c"
  SILVER        = "#E3DEDB"
end

class Ribbon

  WIDTH=35
  HEIGHT=9

  SCALE=3
  
  attr_reader :order
  attr_reader :name
  attr_reader :set
  attr_reader :devices
  
  def initialize(order, name, set: nil, devices: DevicesStandard.new)
    @order=order
    @name=name
    @set=set
    @devices=devices
  end
  
  def drawDevices(n, out)
    devices.drawDevices(n, out)
  end
end

class DevicesStandard
  attr_reader :single
  attr_reader :group
  attr_reader :colour
  
  def initialize(single: "#star", group: "#star_laurel", colour: Metals::BRONZE)
    @single=single
    @group=group
    @colour=colour
  end

  def drawDevices(n, out)
    device = :single
    positions=[]
    case n
    when 2
      positions=[0]
    when 3
      positions=[-Ribbon::WIDTH/6.0, Ribbon::WIDTH/6.0]
    when 4
      positions=[-Ribbon::WIDTH/3.25, 0, Ribbon::WIDTH/3.25]
    when 5...10
      device=:group
      positions=[0]
    when 10...15
      device=:group
      positions=[-Ribbon::WIDTH/6.0, Ribbon::WIDTH/6.0]
    when 15...Float::INFINITY
      device=:group
      positions=[-Ribbon::WIDTH/3.25, 0, Ribbon::WIDTH/3.25]
    end
    positions.each do |x|
      drawDevice(device, x, out)
    end
  end

  def drawDevice(n, x, out)
    device = case n
             when :single
               single
             when :group
               group
             end
    out<< "<use x=\"#{x*Ribbon::SCALE}\" xlink:href=\"#{device}\" class=\"device\" style=\"filter:url(\'#shadow\');fill: #{colour};\" />"
  end

  def values(max)
    [1,2,3,4,5,10,15].select {|x| x<=max}
  end
end

class DevicesSpecialWithStars < DevicesStandard
  attr_reader :special
  attr_reader :special_colour
  def initialize(single: "#star", group: "#star_laurel", colour: Metals::BRONZE, special: "#fleet_e", special_colour: Metals::SILVER)
    super(single: single, group: group, colour: colour)
    @special=special
    @special_colour=special_colour
  end

  def drawDevices(n, out)
    device = :single
    positions=[]
    case n
    when 2
      positions=[-Ribbon::WIDTH/3.25]
    when 3..4
      positions=[-Ribbon::WIDTH/3.25, Ribbon::WIDTH/3.25]
    when 5...10
      device=:group
      positions=[-Ribbon::WIDTH/3.25]
    when 10...Float::INFINITY
      device=:group
      positions=[-Ribbon::WIDTH/3.25, Ribbon::WIDTH/3.25]
    end
    drawSpecial(0.0, out)
    positions.each do |x|
      drawDevice(device, x, out)
    end
  end
  
  def drawSpecial(x, out)
    out<< "<use x=\"#{x*Ribbon::SCALE}\" xlink:href=\"#{special}\" class=\"device\" style=\"filter:url(\'#shadow\');fill: #{special_colour};\" />"
  end
  
  def values(max)
    [1,2,3,5,10].select {|x| x<=max}
  end
 
end

class DevicesNone < DevicesStandard
  def initialize()
    super()
  end

  def drawDevices(n, out)
    super(0, out)
  end
  
  def values(max)
    [1]
  end
end

class DevicesOne < DevicesSpecialWithStars
  def initialize(device, colour)
    super(special: device, special_colour: colour )
  end

  def drawDevices(n, out)
    super(0, out)
  end
  
  def values(max)
    [1]
  end
end

class DevicesFrame
  attr_reader :frame_colour
  attr_reader :sub_devices
  
  def initialize(frame_colour: Metals::GOLD, sub_devices: DevicesStandard.new)
    @frame_colour=frame_colour
    @sub_devices=sub_devices
  end
  
  def drawDevices(n, out)
    out<< "<use xlink:href=\"#unitFrame\" class=\"device\" style=\"filter:url(\'#shadow\');fill: #{frame_colour};\" />"
    sub_devices.drawDevices(n,out)
  end
  
  def values(max)
    sub_devices.values(max)
  end

end

class SolidRibbon < Ribbon
  
  attr_reader :colour
  
  def initialize(order, name, colour, set: nil, devices: DevicesStandard.new)
    super(order, name, set: set, devices: devices)
    @colour=colour
  end
  
  def draw(out)
    out << "<rect width=\"#{WIDTH*SCALE}\" height=\"#{HEIGHT*SCALE}\" style=\"fill:rgb(#{colour.join(", ")});\"/>"
  end

end

class VerticalRibbon < Ribbon
  attr_reader :colours
  
  def initialize(order, name, colours, set: nil, devices: DevicesStandard.new)
    super(order, name, set: set, devices: devices)
    @colours=colours
  end
  
  def draw(out)
    x=0
    colours.each do |colour, width|
      out << "<rect x=\"#{x*SCALE}\" width=\"#{width*SCALE}\" height=\"#{HEIGHT*SCALE}\" style=\"fill:rgb(#{colour.join(", ")});\"/>"
      x+=width
    end
    #out << "<!-- ERROR total width was #{x} instead of #{WIDTH} -->" unless x==#{WIDTH}
  end
end

class MirrorRibbon < VerticalRibbon
  attr_reader :colours
  
  def initialize(order, name, colours, set: nil, devices: DevicesStandard.new)
    
    side_colours = colours[0..-2]
    middle_colour,middle_width = colours[-1]
    
    mcolours=[]+side_colours
    mcolours<<[middle_colour, WIDTH-2*side_colours.map{|c,w|w}.inject(0,:+)]
    mcolours+=side_colours.reverse
    
    super(order, name, mcolours, set: set, devices: devices)
  end

end

class HorizontalRibbon < Ribbon
  attr_reader :colours
  
  def initialize(order, name, colours, set: nil, devices: DevicesStandard.new)
    super(order, name, set: set, devices: devices)
    @colours=colours
  end
  
  def draw(out)
    y=0
    catch(:done) do
      while true
        colours.each do |colour, width|
          if(y+width<=HEIGHT)
            out << "<rect y=\"#{y*SCALE}\" width=\"#{WIDTH*SCALE}\" height=\"#{width*SCALE}\" style=\"fill:rgb(#{colour.join(", ")});\"/>"
          else
            out << "<rect y=\"#{y*SCALE}\" width=\"#{WIDTH*SCALE}\" height=\"#{(HEIGHT-y)*SCALE}\" style=\"fill:rgb(#{colour.join(", ")});\"/>"
          end
          y+=width
          throw :done if y>=HEIGHT
        end
      end
    end
  end

end

RIBBONS = {}

GSN_CROSS_STRIPE = Ribbon::WIDTH/7
[
  ['CC', 'Cross of Courage', [Colours::ROSE, Colours::VIOLET]],
  ['ArC', 'Armsman\'s Cross', [Colours::COOL_GREY, Colours::COOL_GREY]],
  ['SwC', 'Sword\'s Cross', [Colours::BLOOD_RED, Colours::COOL_GREY]]
]. each do |abbr, name, colours|
  RIBBONS[abbr+'Fe']=MirrorRibbon.new(nil, name+" in Steel", [[colours[0], GSN_CROSS_STRIPE],[colours[1], nil]], devices: DevicesNone.new)
  RIBBONS[abbr+'Cu']=MirrorRibbon.new(nil, name+" in Bronze", [[colours[0], GSN_CROSS_STRIPE],[colours[1], GSN_CROSS_STRIPE*2], [Colours::BRONZE, nil]], devices: DevicesNone.new)
  RIBBONS[abbr+'Ag']=MirrorRibbon.new(nil, name+" in Silver", [[colours[0], GSN_CROSS_STRIPE],[colours[1], GSN_CROSS_STRIPE*1.5], [Colours::SILVER, GSN_CROSS_STRIPE*0.5],[Colours::BRONZE, nil]], devices: DevicesNone.new)
  RIBBONS[abbr+'Au']=MirrorRibbon.new(nil, name+" in Gold", [[colours[0], GSN_CROSS_STRIPE],[colours[1], GSN_CROSS_STRIPE], [Colours::GOLD, GSN_CROSS_STRIPE*0.5],[Colours::SILVER, GSN_CROSS_STRIPE*0.5],[Colours::BRONZE, nil]], devices: DevicesNone.new)
  RIBBONS[abbr+'X']=MirrorRibbon.new(nil, name+" with Crossed Swords", [[colours[0], GSN_CROSS_STRIPE],[colours[1], GSN_CROSS_STRIPE], [Colours::GOLD, GSN_CROSS_STRIPE*0.5],[Colours::SILVER, GSN_CROSS_STRIPE*0.5],[Colours::BRONZE, nil]], devices: DevicesOne.new("#swords", Metals::GOLD))
  RIBBONS[abbr+'W']=MirrorRibbon.new(nil, name+" with Laurel Wreath", [[colours[0], GSN_CROSS_STRIPE],[colours[1], GSN_CROSS_STRIPE], [Colours::GOLD, GSN_CROSS_STRIPE*0.5],[Colours::SILVER, GSN_CROSS_STRIPE*0.5],[Colours::BRONZE, nil]], devices: DevicesOne.new("#swords_laurel", Metals::GOLD))
  RIBBONS[abbr+'D']=MirrorRibbon.new(nil, name+" with Diamonds", [[colours[0], GSN_CROSS_STRIPE],[colours[1], GSN_CROSS_STRIPE], [Colours::GOLD, GSN_CROSS_STRIPE*0.5],[Colours::SILVER, GSN_CROSS_STRIPE*0.5],[Colours::BRONZE, nil]], devices: DevicesOne.new("#swords_diamonds", Metals::GOLD))
end


RIBBONS['PMV']=VerticalRibbon.new(1, "Parliamentary Medal of Valour", [[Colours::CRIMSON, Ribbon::WIDTH/3.0],[Colours::NAVY_BLUE,Ribbon::WIDTH/3.0],[Colours::WHITE,Ribbon::WIDTH/3.0]])
RIBBONS['SG']=SolidRibbon.new(1, "Star of Grayson", Colours::CRIMSON, devices: DevicesOne.new("#star_of_grayson", Metals::GOLD))
RIBBONS['QCB']=SolidRibbon.new(2, "Queen's Cross for Bravery", Colours::FOREST_GREEN)
RIBBONS['AM']=SolidRibbon.new(2, "Austin Medal", Colours::LIGHT_BLUE)

RIBBONS['KSK']=MirrorRibbon.new(3, "Most Noble Order of the Star Kingdom", [[Colours::GOLD, 2],[Colours::ROYAL_BLUE, 31]], devices: DevicesNone.new)
RIBBONS['DSS']=MirrorRibbon.new(3, "Distinguished Service Star", [[Colours::VIOLET, 14.5],[Colours::CRIMSON, nil]], devices: DevicesNone.new)
RIBBONS['GCR']=MirrorRibbon.new(4, "Knight Grand Cross, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger, devices: DevicesOne.new("#crown", Metals::SILVER))
RIBBONS['GCGL']=MirrorRibbon.new(nil, "Knight Grand Cross, Golden Lion", [[Colours::GOLD, 2],[Colours::DARK_GREEN, 31]], set: :order_golden_lion, devices: DevicesOne.new("#crown", Metals::SILVER))
RIBBONS['GCE']=MirrorRibbon.new(5, "Knight Grand Cross, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth, devices: DevicesOne.new("#crown", Metals::SILVER))

RIBBONS['OM']=VerticalRibbon.new(6, "Most Distinguished Order of Merit", [[Colours::GOLD, 2],[Colours::ROYAL_BLUE,15.5],[Colours::WHITE,15.5],[Colours::GOLD,2]], devices: DevicesNone.new)
RIBBONS['KDR']=MirrorRibbon.new(7,  "Knight Commander, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['KDGL']=MirrorRibbon.new(nil,  "Knight Commander, Golden Lion", [[Colours::GOLD, 2],[Colours::DARK_GREEN, 31]], set: :order_golden_lion, devices: DevicesNone.new)
RIBBONS['KDE']=MirrorRibbon.new(8,  "Knight Commander, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['MMC']=MirrorRibbon.new(nil,  "Commander, Legion of Merit", [[Colours::COOL_GREY, 5],[Colours::CRIMSON, 5]], set: :order_military_merit, devices: DevicesOne.new("#swords", Metals::GOLD))

RIBBONS['KCR']=MirrorRibbon.new(9,  "Knight Companion, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['KCE']=MirrorRibbon.new(nil, "Knight Companion, Golden Lion", [[Colours::GOLD, 2],[Colours::DARK_GREEN, 31]], set: :order_golden_lion, devices: DevicesNone.new)
RIBBONS['KCE']=MirrorRibbon.new(10, "Knight Companion, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['AC']=MirrorRibbon.new(nil, "Adrienne Cross", [[Colours::ROYAL_BLUE, 4],[Colours::SILVER, 2.5],[Colours::SCARLET, Ribbon::WIDTH/2.0-4-2.5-1.75],[Colours::GOLD, nil]])
RIBBONS['MC']=SolidRibbon.new(11, "Manticore Cross", Colours::BLOOD_RED)
RIBBONS['OC']=SolidRibbon.new(12, "Osterman Cross", Colours::NAVY_BLUE)

RIBBONS['KR']=MirrorRibbon.new(13, "Knight, King Roger", [[Colours::GOLD, 1],[Colours::SCARLET, 33]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['KE']=MirrorRibbon.new(14, "Knight, Queen Elizabeth", [[Colours::GOLD, 1],[Colours::SILVER, 33]], set: :order_queen_elizabeth, devices: DevicesNone.new)
RIBBONS['CR']=MirrorRibbon.new(15, "Companion, King Roger", [[Colours::GOLD, 1],[Colours::SCARLET, 33]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['CGL']=MirrorRibbon.new(nil, "Companion, Golden Lion", [[Colours::GOLD, 1],[Colours::DARK_GREEN, 33]], set: :order_golden_lion, devices: DevicesNone.new)
RIBBONS['CE']=MirrorRibbon.new(16, "Companion, Queen Elizabeth", [[Colours::GOLD, 1],[Colours::SILVER, 33]], set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['SC']=MirrorRibbon.new(17, "Saganami Cross", [[Colours::WHITE, 5],[Colours::SCARLET, 25]])
RIBBONS['DGC']=MirrorRibbon.new(18, "Distinguished Gallantry Cross", [[Colours::NAVY_BLUE, 12],[Colours::PURPLE, 4],[Colours::NAVY_BLUE, 3]])

RIBBONS['OR']=SolidRibbon.new(19, "Officer, King Roger", Colours::SCARLET, set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['OGL']=SolidRibbon.new(nil, "Officer, Golden Lion", Colours::DARK_GREEN, set: :order_golden_lion, devices: DevicesNone.new)
RIBBONS['OE']=SolidRibbon.new(20, "Officer, Queen Elizabeth", Colours::SILVER, set: :order_queen_elizabeth, devices: DevicesNone.new)
RIBBONS['MMO']=MirrorRibbon.new(nil,  "Officer, Legion of Merit", [[Colours::COOL_GREY, 5],[Colours::CRIMSON, 5]], set: :order_military_merit, devices: DevicesOne.new("#swords", Metals::SILVER))

RIBBONS['OG']=HorizontalRibbon.new(21, "Order of Gallantry", [[Colours::LIGHT_BLUE, 3],[Colours::WHITE, 2]])

RIBBONS['NS']=MirrorRibbon.new(22, "Navy Star", [[Colours::NAVY_BLUE, 12],[Colours::PURPLE, 4],[Colours::WHITE, 3]])
RIBBONS['NSG']=MirrorRibbon.new(nil, "Naval Star of Gallantry", [[Colours::LIGHT_BLUE, 15],[Colours::FOREST_GREEN, nil]])

RIBBONS['DSO']=MirrorRibbon.new(23, "Distinguished Service Order", [[Colours::NAVY_BLUE, 6],[Colours::BLOOD_RED,23]])
RIBBONS['DSD']=MirrorRibbon.new(nil, "Distinguished Service Decoration", [[Colours::VIOLET, 14.5],[Colours::CRIMSON, 2],[Colours::WHITE, nil]])

RIBBONS['MR']=SolidRibbon.new(24, "Member, King Roger", Colours::SCARLET, set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['MGL']=SolidRibbon.new(nil, "Member, King RogerGolden Lion", Colours::DARK_GREEN, set: :order_golden_lion, devices: DevicesNone.new)
RIBBONS['ME']=SolidRibbon.new(25, "Member, Queen Elizabeth", Colours::SILVER, set: :order_queen_elizabeth, devices: DevicesNone.new)
RIBBONS['MMM']=MirrorRibbon.new(nil,  "Officer, Legion of Merit", [[Colours::COOL_GREY, 5],[Colours::CRIMSON, 5]], set: :order_military_merit, devices: DevicesOne.new("#swords", Metals::BRONZE))

RIBBONS['MT']=nil # 26, Monarch's Thanks, not a ribbon

RIBBONS['CGM']=MirrorRibbon.new(27, "Conspicuous Gallantry Medal", [[Colours::NAVY_BLUE, 8.5],[Colours::WHITE,4],[Colours::NAVY_BLUE, 10]])

RIBBONS['GS']=MirrorRibbon.new(28, "The Gryphon Star", [[Colours::FOREST_GREEN, 9],[Colours::WHITE,5],[Colours::FOREST_GREEN, 7]])

RIBBONS['OCN']=MirrorRibbon.new(29, "Order of the Crown for Naval Service", [[Colours::NAVY_BLUE, 15.5],[Colours::BLOOD_RED,4]])

RIBBONS['WS']=nil # 30, Wound Stripe, not a ribbon
RIBBONS['WM']=MirrorRibbon.new(nil, "Wound Medal", [[Colours::CRIMSON, 13],[Colours::WHITE,3],[Colours::CRIMSON, nil]])

RIBBONS['QBM']=MirrorRibbon.new(31, "Queen's Bravery Medal", [[Colours::CRIMSON,2],[Colours::FOREST_GREEN,10.5],[Colours::CRIMSON,4],[Colours::WHITE,2]])

RIBBONS['SXC']=MirrorRibbon.new(32, "Sphinx Cross", [[Colours::PURPLE,10],[Colours::WHITE,3],[Colours::CRIMSON,3],[Colours::WHITE,3]])

RIBBONS['RHDSM']=MirrorRibbon.new(33, "Royal Household Distinguished Service Medal", [[Colours::SILVER,3],[Colours::GOLD,3],[Colours::ROYAL_BLUE,nil]], devices: DevicesNone.new)

RIBBONS['MiD']=nil # 34, Mentioned in Dispatches, not a ribbon

RIBBONS['RM']=MirrorRibbon.new(35, "Medal, King Roger", [[Colours::SCARLET,(Ribbon::WIDTH-2)/2],[Colours::GOLD,2]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['GLM']=MirrorRibbon.new(nil, "Medal, Golden Lion", [[Colours::DARK_GREEN,(Ribbon::WIDTH-2)/2],[Colours::GOLD,2]], set: :order_golden_lion, devices: DevicesNone.new)
RIBBONS['EM']=MirrorRibbon.new(36, "Medal, Queen Elizabeth", [[Colours::SILVER,(Ribbon::WIDTH-2)/2],[Colours::GOLD,2]], set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['CBM']=MirrorRibbon.new(37, "Conspicuous Bravery Medal", [[Colours::FOREST_GREEN,12.5],[Colours::WHITE,4],[Colours::CRIMSON,2]])

RIBBONS['CSM']=MirrorRibbon.new(38, "Conspicuous Service Medal", [[Colours::SCARLET,2],[Colours::EMERALD,8],[Colours::SCARLET,15]])
RIBBONS['MSM']=MirrorRibbon.new(39, "Meritorious Service Medal", [[Colours::EMERALD,2],[Colours::SCARLET,8],[Colours::EMERALD,15]])


RIBBONS['NCD']=MirrorRibbon.new(40, "Navy Commendation Decoration", [[Colours::SCARLET,4.5],[Colours::EMERALD,3],[Colours::PURPLE,2],[Colours::EMERALD,3],[Colours::SCARLET,nil]])
RIBBONS['NAM']=MirrorRibbon.new(41, "Navy Achievement Medal", [[Colours::PURPLE,4.5],[Colours::EMERALD,3],[Colours::SCARLET,2],[Colours::EMERALD,3],[Colours::PURPLE,nil]])
RIBBONS['MAM']=MirrorRibbon.new(41, "Marine Achievement Medal", [[Colours::PURPLE,4.5],[Colours::EMERALD,3],[Colours::SCARLET,2],[Colours::EMERALD,3],[Colours::PURPLE,nil]])

RIBBONS['LHC']=MirrorRibbon.new(42, "List of Honor Citation", [[Colours::SPACE_BLACK,5],[Colours::CRIMSON, nil]], devices: DevicesFrame.new(frame_colour: Metals::GOLD, sub_devices: DevicesOne.new("#scroll", Metals::GOLD)))
RIBBONS['LHCP']=MirrorRibbon.new(nil, "Personal List of Honor Citation", [[Colours::SPACE_BLACK,5],[Colours::CRIMSON, nil]], devices: DevicesFrame.new(frame_colour: Metals::GOLD, sub_devices: DevicesNone.new))
RIBBONS['RUC']=MirrorRibbon.new(43, "Royal Unit Citation for Gallantry", [[Colours::SCARLET,5],[Colours::GOLD, nil]], devices: DevicesFrame.new(frame_colour: Metals::GOLD))
RIBBONS['PUC']=SolidRibbon.new(43, "Protector's Unit Citation for Gallantry", Colours::LIGHT_BLUE, devices: DevicesFrame.new(frame_colour: Metals::GOLD))
RIBBONS['RMU']=MirrorRibbon.new(44, "Royal Meritorious Unit Citation", [[Colours::GOLD,5],[Colours::SCARLET, nil]], devices: DevicesFrame.new(frame_colour: Metals::GOLD))
RIBBONS['MUA']=SolidRibbon.new(44, "Meritorious Unit Award", Colours::EMERALD, devices: DevicesFrame.new(frame_colour: Metals::GOLD))

RIBBONS['FEA']=MirrorRibbon.new(45, "Fleet Excellence Award", [[Colours::CRIMSON,2],[Colours::GOLD, 2],[Colours::SPACE_BLACK, nil]], devices: DevicesSpecialWithStars.new)
RIBBONS['FEAG']=MirrorRibbon.new(45, "Fleet Excellence Award in Gold", [[Colours::CRIMSON,2],[Colours::GOLD, 2],[Colours::SPACE_BLACK, nil]], devices: DevicesSpecialWithStars.new(special_colour: Metals::GOLD))
RIBBONS['AREA']=MirrorRibbon.new(45, "Army Regimental Excellence Award", [[Colours::ORANGE,2],[Colours::CRIMSON, 2],[Colours::FOREST_GREEN, nil]], devices: DevicesSpecialWithStars.new)
RIBBONS['AREAG']=MirrorRibbon.new(45, "Army Regimental Excellence Award in Gold", [[Colours::ORANGE,2],[Colours::CRIMSON, 2],[Colours::FOREST_GREEN, nil]], devices: DevicesSpecialWithStars.new(special_colour: Metals::GOLD))

RIBBONS['POW']=MirrorRibbon.new(46, "Prisoner of War Medal", [[Colours::GOLD,2],[Colours::CHARCOAL_GREY, 11.5],[Colours::CRIMSON,nil]])

RIBBONS['SvC']=MirrorRibbon.new(47, "Survivor's Cross", [[Colours::SILVER,3],[Colours::SCARLET, 10],[Colours::GOLD,3],[Colours::SCARLET, nil]])

RIBBONS['SAPC']=MirrorRibbon.new(48, "Silesian Anti-Piracy Campaign Medal", [[Colours::SCARLET,5],[Colours::SAPPHIRE,11],[Colours::GOLD,3]])

RIBBONS['GMC']=MirrorRibbon.new(nil, "Grayson-Masada War Campaign Medal", [[Colours::ROYAL_BLUE,14.5],[Colours::CRIMSON,2],[Colours::ROYAL_BLUE,nil]])
RIBBONS['SGMC']=MirrorRibbon.new(nil, "Second Grayson-Masada War Campaign Medal", [[Colours::CRIMSON,2],[Colours::ROYAL_BLUE,12.5],[Colours::CRIMSON,2],[Colours::ROYAL_BLUE,nil]])

RIBBONS['MOM']=MirrorRibbon.new(49, "Masadan Occupation Medal", [[Colours::CRIMSON,4],[Colours::GOLD,3.8],[Colours::CRIMSON,2],[Colours::GOLD,3.8],[Colours::CRIMSON,2],[Colours::GOLD,3.8]])

RIBBONS['HWC']=MirrorRibbon.new(50, "Havenite War Campaign Medal", [[Colours::BLOOD_RED,2],[Colours::FOREST_GREEN,9.5],[Colours::WHITE,4],[Colours::SPACE_BLACK,nil]])
RIBBONS['GSNHWC']=MirrorRibbon.new(50, "GSN Havenite War Campaign Medal", [[Colours::ROYAL_BLUE,14.5],[Colours::DARK_GREEN,2],[Colours::ROYAL_BLUE,nil]])
RIBBONS['HOSM']=MirrorRibbon.new(51, "Havenite Operational Service Medal", [[Colours::BLOOD_RED,2],[Colours::FOREST_GREEN,9.5],[Colours::DARK_GREEN,4],[Colours::GOLD,nil]])

RIBBONS['MHWM']=VerticalRibbon.new(52, "Manticore and Havenite 1905-1922 War Medal", [[Colours::SILVER,3],[Colours::DARK_GREEN, (Ribbon::WIDTH-9)/2],[Colours::SPACE_BLACK,3],[Colours::CRIMSON, (Ribbon::WIDTH-9)/2], [Colours::GOLD, 3]], devices: DevicesOne.new("#manticore", Metals::SILVER))

# Old Ribbon Board Generator seemed to be way off here so I guessed
gacmband=(Ribbon::WIDTH-5)/6.0
RIBBONS['GACM']=MirrorRibbon.new(53, "Grand Alliance Campaign Medal", [[Colours::YELLOW,1],[Colours::ROYAL_BLUE,gacmband],[Colours::EMERALD,gacmband],[Colours::SCARLET,gacmband],[Colours::SPACE_BLACK,1],[Colours::YELLOW,1]])

RIBBONS['KR3CM']=MirrorRibbon.new(54, "King Roger III Coronation Medal", [[Colours::SILVER,2],[Colours::ROYAL_BLUE,14.5],[Colours::GOLD,2]], devices: DevicesNone.new)
RIBBONS['QE3CM']=MirrorRibbon.new(55, "Queen Elizabeth III Coronation Medal", [[Colours::SILVER,2],[Colours::ROYAL_BLUE,12.5],[Colours::CRIMSON,2],[Colours::GOLD,2]], devices: DevicesNone.new)

RIBBONS['MCAM']=MirrorRibbon.new(56, "Manticoran Combat Action Medal", [[Colours::FOREST_GREEN,6],[Colours::BLOOD_RED,nil]])

a=Colours::CRIMSON
b=Colours::ROYAL_BLUE
RIBBONS['MtSM']=MirrorRibbon.new(57, "Manticoran Service Medal", [[a,2],[Colours::GOLD,2],[a,2],[Colours::GOLD,2],[b,nil]], set: :manticoran_service)
a=Colours::ROYAL_BLUE
b=Colours::CRIMSON
RIBBONS['MRSM']=MirrorRibbon.new(58, "Manticoran Reserve Service Medal", [[a,2],[Colours::GOLD,2],[a,2],[Colours::GOLD,2],[b,nil]], set: :manticoran_service, devices: DevicesNone.new)
RIBBONS['LSGC']=MirrorRibbon.new(nil, "Grayson Space Navy Long Service and Good Conduct Medal", [[Colours::LIGHT_BLUE,2],[Colours::ROYAL_BLUE,14.5],[Colours::LIGHT_BLUE,nil]], set: :greyson_service)

RIBBONS['GCM']=MirrorRibbon.new(59, "Good Conduct Medal", [[Colours::ORANGE,7.5],[Colours::CRIMSON,3],[Colours::ORANGE,nil]])
RIBBONS['RSGC']=MirrorRibbon.new(nil, "Grayson Space Navy Reserve Long Service and Good Conduct Medal", [[Colours::LIGHT_BLUE,2],[Colours::ROYAL_BLUE,nil]], set: :greyson_service, devices: DevicesNone.new)

RIBBONS['SSD']=MirrorRibbon.new(60, "Space Service Deployment Ribbon", [[Colours::GOLD,4],[Colours::SPACE_BLACK,nil]], devices: DevicesNone.new)
RIBBONS['SSR']=MirrorRibbon.new(60, "Space Service Ribbon", [[Colours::LIGHT_BLUE,2],[Colours::NAVY_BLUE,nil]], devices: DevicesNone.new)
RIBBONS['ASDR']=MirrorRibbon.new(60, "Army Space Duty Ribbon", [[Colours::DARK_GREEN,2],[Colours::SPACE_BLACK,14.5],[Colours::DARK_GREEN,2]], devices: DevicesNone.new)

a=Colours::ROSE
b=Colours::CHARCOAL_GREY
RIBBONS['RHE']=MirrorRibbon.new(61, "Naval Rifle High Expert Award", [[a,2],[b,6],[a,2],[b,6.5],[a,2]], set: :navy_rifle, devices: DevicesNone.new)
RIBBONS['RE']=MirrorRibbon.new(63, "Naval Rifle Expert Award", [[a,2],[b,6],[a,2],[b,nil]], set: :navy_rifle, devices: DevicesNone.new)
RIBBONS['RS']=MirrorRibbon.new(65, "Naval Rifle Sharpshooter Award", [[a,2],[b,14.5],[a,2]], set: :navy_rifle, devices: DevicesNone.new)
#RIBBONS['RM']=nil # 67, Naval Pistol Marksman Certificate, not a ribbon

RIBBONS['PHE']=MirrorRibbon.new(62, "Naval Pistol High Expert Award", [[b,8],[a,2],[b,4.5],[a,6]], set: :navy_pistol, devices: DevicesNone.new)
RIBBONS['PE']=MirrorRibbon.new(64, "Naval Pistol Expert Award", [[a,2],[b,12.5],[a,6]], set: :navy_pistol, devices: DevicesNone.new)
RIBBONS['PS']=MirrorRibbon.new(66, "Naval Pistol Sharpshooter Award", [[b,14.5],[a,6]], set: :navy_pistol, devices: DevicesNone.new)
#RIBBONS['PM']=nil # 68, Naval Rifle Marksman Certificate, not a ribbon

RIBBONS['RTR']=MirrorRibbon.new(69, "Recruit Training Ribbon", [[Colours::CRIMSON,1],[Colours::FOREST_GREEN,16],[Colours::CRIMSON,1]], devices: DevicesNone.new)

RIBBONS['NCOSCR']=MirrorRibbon.new(70, "Non-Commissioned Officers Senior Course Ribbon", [[Colours::EMERALD,3],[Colours::WHITE,2],[Colours::YELLOW,2],[Colours::WHITE,2],[Colours::EMERALD,3],[Colours::ROYAL_BLUE,nil]], devices: DevicesNone.new)

RIBBONS['AFSM']=MirrorRibbon.new(71, "Armed Forces Service Medal", [[Colours::ROYAL_BLUE,5],[Colours::WHITE,3],[Colours::CRIMSON,nil]], devices: DevicesNone.new)

class RibbonEntry
  attr_reader :ribbon, :count

  def initialize(ribbon, count: 1)
    @ribbon=ribbon
    @count=count
  end

  def addRibbon
    @count+=1
  end
end

def ribbon_collapse(abbrs)
  ribbons = abbrs.map{|abbr| RIBBONS[abbr]}.compact.sort!{|r1, r2| r1.order<=>r2.order}
  entries = []
  sets = Set.new
  last=nil
  ribbons.each do |ribbon|
    $stderr.puts "#{ribbon.order}\t#{ribbon.name}\t\t#{ribbon.set} "
    if last==ribbon
      $stderr.puts "Same as last, adding "
      entries[-1].addRibbon
    elsif not ribbon.set.nil?
      if not sets.include? ribbon.set
        sets.add ribbon.set
        entries << RibbonEntry.new(ribbon)
      end
    else
      entries << RibbonEntry.new(ribbon)
    end 
    last=ribbon
  end
  return entries
end

def ribbon_out(ribbon, n, out, defs)
  return if ribbon.nil?
  title = ribbon.name
  title+=" (&#215;#{n})"if(n>1)
  out << "<svg xmlns=\"http://www.w3.org/2000/svg\"  xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"#{Ribbon::WIDTH*Ribbon::SCALE}\" height=\"#{Ribbon::HEIGHT*Ribbon::SCALE}\" title=\"#{title}\">"
  if defs
    out << <<EOS
              <defs>
		<linearGradient id="ribbon-ridges" spreadMethod="repeat" x1="0" x2="0" y1="0" y2="#{1.0/Ribbon::HEIGHT}">
		  <stop offset="0" style="stop-color:white; stop-opacity:1;"/>
		  <stop offset="0.5" style="stop-color:white; stop-opacity:0;"/>
		  <stop offset="0.5" style="stop-color:black; stop-opacity:0;"/>
		  <stop offset="1" style="stop-color:black; stop-opacitity:0;"/>
		</linearGradient>
		<linearGradient id="ribbon-shape" x1="0" x2="0" y1="0" y2="1">
		  <stop offset="0" style="stop-color:white; stop-opacity:1;"/>
		  <stop offset="0.25" style="stop-color:white; stop-opacity:0;"/>
		  <stop offset="0.75" style="stop-color:black; stop-opacity:0;"/>
		  <stop offset="1" style="stop-color:black; stop-opacitity:0;"/>
		</linearGradient>
		<symbol id="ribbon-shade">
		  <rect x="#{Ribbon::SCALE}" width="#{(Ribbon::WIDTH-2)*Ribbon::SCALE}" height="#{Ribbon::HEIGHT*Ribbon::SCALE}" style="opacity:0.125; fill:url(#ribbon-ridges);"/>
		  <rect width="#{Ribbon::WIDTH*Ribbon::SCALE}" height="#{Ribbon::HEIGHT*Ribbon::SCALE}" style="opacity:0.25; fill:url(#ribbon-shape);"/>
		</symbol>
		<symbol id="star" viewbox="-13.5 -13.5 27 27">
                  <g transform="translate(#{Ribbon::WIDTH*Ribbon::SCALE/2},#{Ribbon::HEIGHT*Ribbon::SCALE/2})">
		  <path
		     style="stroke:none;"
		     d="m 0.00124526,-9.8799597 2.41080364,3.2564908 3.940014,-0.944982 -0.2464492,4.0442513 3.6256485,1.808694 L 6.9428765,1.2241562 8.5576784,4.9402181 4.5320729,5.3997899 3.3804443,9.2844331 0.00124446,7.0488762 -3.3779547,9.2844329 -4.5295837,5.3997892 -8.5551886,4.9402177 l 1.6148019,-3.7160626 -2.7883854,-2.9396612 3.625649,-1.8086944 -0.2464494,-4.0442507 3.9400146,0.9449819 z" />
		  <g
		     transform="translate(-52.499607,-13.500763)">
		    <path
		       d="M 46.148438,5.9316406 52.5,13.5 50.089844,6.8769531 46.148438,5.9316406 Z M 52.5,13.5 58.851562,5.9316406 54.910156,6.8769531 52.5,13.5 Z"
		       style="fill:#ffffff;fill-opacity:0.71142859;stroke:none;" />
		    <path
		       d="M 46.396484,9.9765625 42.769531,11.785156 52.5,13.5 46.396484,9.9765625 Z M 52.5,13.5 62.230469,11.785156 58.603516,9.9765625 52.5,13.5 Z"
		       style="fill:#ffffff;fill-opacity:0.50571445;stroke:none;" />
		    <path
		       d="M 52.5,13.5 61.056641,18.439453 59.441406,14.724609 52.5,13.5 Z m 0,0 -6.941406,1.224609 -1.615235,3.714844 L 52.5,13.5 Z"
		       style="fill:#ffffff;fill-opacity:0.15142858;stroke:none;" />
		    <path
		       d="M 52.5,13.5 55.878906,22.785156 57.03125,18.900391 52.5,13.5 Z m 0,0 -4.53125,5.400391 1.152344,3.884765 L 52.5,13.5 Z"
		       style="fill:#000000;fill-opacity:0.27428571;stroke:none;" />
		    <path
		       d="M 52.5,13.5 49.121094,22.785156 52.5,20.548828 55.878906,22.785156 52.5,13.5 Z"
		       style="fill:#000000;fill-opacity:0.61142853;stroke:none;" />
		    <path
		       d="m 52.5,13.5 4.53125,5.400391 4.025391,-0.460938 L 52.5,13.5 Z m 0,0 -8.556641,4.939453 4.025391,0.460938 L 52.5,13.5 Z"
		       style="fill:#000000;fill-opacity:0.54857142;stroke:none;" />
		    <path
		       d="M 42.769531,11.785156 45.558594,14.724609 52.5,13.5 42.769531,11.785156 Z M 52.5,13.5 59.441406,14.724609 62.230469,11.785156 52.5,13.5 Z"
		       style="fill:#000000;fill-opacity:0.34285715;stroke:none;" />
		    <path
		       d="M 46.148438,5.9316406 46.396484,9.9765625 52.5,13.5 46.148438,5.9316406 Z M 52.5,13.5 58.603516,9.9765625 58.851562,5.9316406 52.5,13.5 Z"
		       style="fill:#000000;fill-opacity:0.07142855;stroke:none;" />
		    <path
		       d="M 52.5,3.6191406 50.089844,6.8769531 52.5,13.5 54.910156,6.8769531 52.5,3.6191406 Z"
		       style="fill:#ffffff;fill-opacity:0.40285716;stroke:none;" />
		  </g>
		  <g
		     style="fill:none;"
		     transform="translate(-52.498755,-13.499868)">
		    <path
		       style="fill:none;"
		       d="m 52.5,3.6199083 2.410804,3.2564908 3.940014,-0.944982 -0.246449,4.0442513 3.625648,1.8086936 -2.788385,2.939662 1.614801,3.716062 -4.025605,0.459572 -1.151629,3.884643 -3.3792,-2.235557 -3.379199,2.235557 -1.151629,-3.884644 -4.025605,-0.459571 1.614802,-3.716063 -2.788385,-2.939661 3.625649,-1.8086945 -0.246449,-4.0442507 3.940014,0.9449819 z" />
		    <path
		       d="m 52.5,3.6199083 -8.52e-4,9.8791967" />
		    <path
		       d="M 54.909304,6.8760584 52.5,13.500027" />
		    <path
		       d="m 46.149182,5.931417 6.349573,7.568451" />
		    <path
		       d="M 50.087829,6.8771019 52.5,13.500027" />
		    <path
		       d="m 42.769982,11.784362 9.728962,1.716343" />
		    <path
		       d="M 46.395036,9.9770856 52.5,13.500027" />
		    <path
		       d="m 43.943566,18.440086 8.556061,-4.938861" />
		    <path
		       d="M 45.558823,14.725493 52.5,13.500027" />
		    <path
		       d="m 49.1208,22.784302 3.379684,-9.283118" />
		    <path
		       d="M 47.970464,18.900491 52.5,13.500027" />
		    <path
		       d="m 55.8792,22.784302 -3.378086,-9.2837"/>
		    <path
		       d="M 52.501526,20.548552 52.5,13.500027" />
		    <path
		       d="M 61.056434,18.440086 52.501223,13.499751" />
		    <path
		       d="M 57.031874,18.898529 52.5,13.500027" />
		    <path
		       d="m 62.230017,11.784362 -9.729258,1.714667" />
		    <path
		       d="M 59.441707,14.722487 52.5,13.500027" />
		    <path
		       d="M 58.850817,5.931417 52.49994,13.498775" />
		    <path
		       d="M 58.603438,9.9744424 52.5,13.500027" />
		  </g>
                  </g>
		</symbol>
    <symbol
       id="crown" viewbox="-18 -14.5 36 27">
      <g transform="translate(#{Ribbon::WIDTH*Ribbon::SCALE/2},#{Ribbon::HEIGHT*Ribbon::SCALE/2})">
      <path
         transform="scale(0.9)"
         style="stroke:none;"
         d="m 1.0902091e-4,-11.448301 c -0.86762056091,0 -1.01630842091,2.2175071 -1.01630842091,2.2175071 -0.7586735,0.5254381 -0.7750801,1.5860326 -0.7750801,1.5860326 -0.7812993,0 -1.8114815,0.7520347 -1.9260834,2.3411124 -3.42903,-0.9804422 -7.9425781,-3.2141713 -9.7871361,0.1015751 -2.216876,3.9850285 1.142653,7.9107951 3.9611392,10.7326391 l 0,1.0071785 0.5644771,0 0,3.5306382 17.9579771,0 0,-3.5306382 0.5644772,0 0,-1.0071785 C 12.362058,2.7087213 15.721587,-1.2170453 13.504711,-5.2020738 11.660153,-8.5178202 7.146611,-6.2840911 3.717581,-5.3036489 3.6029791,-6.8927266 2.5727968,-7.6447613 1.7914976,-7.6447613 c 0,0 -0.016425,-1.0605945 -0.7750864,-1.5860326 0,0 -0.14868161,-2.2175071 -1.01630217909,-2.2175071 z"/>
      <g
         style="fill:none; stroke: #000000; stroke-width: 0.5px;"
         transform="scale(0.9) matrix(0.62692518,0,0,0.62658076,-297.76119,-240.7634)">
        <path
           d="m 459.73214,393.07649 c -4.49573,-4.50356 -9.85423,-10.76893 -6.31812,-17.12889 3.53612,-6.35997 13.25754,0.11588 18.68419,0.47711" />
        <rect
           width="5.7142944"
           height="21.026804"
           x="472.09821"
           y="372.04971" />
        <path
           d="m 469.02198,375.80696 c 0.17445,-2.5519 1.82622,-3.75725 3.07623,-3.75725" />
        <path
           d="m 474.95536,369.05863 c -2.8125,0 -2.85715,2.99108 -2.85715,2.99108" />
        <path
           d="m 474.95536,365.97827 c -1.38393,0 -1.62187,3.53999 -1.62187,3.53999" />
        <path
           d="m 472.09821,375.13006 c -2.45535,2.05357 -1.33928,17.94642 -1.33928,17.94642" />
        <path
           d="m 459.73214,393.07649 c -3.238,-5.39327 -7.19177,-10.60306 -4.53241,-15.65568 2.65937,-5.05261 6.69504,-0.5984 16.89848,-0.9961" />
        <path
           d="m 474.95536,365.97827 0,-4.24107" />
        <path
           d="m 474.95536,363.9247 -2.54464,0" />
        <path
           d="m 477.5,363.9247 -2.54464,0" />
        <path
           d="m 490.17857,393.07649 c 4.49573,-4.50356 9.85423,-10.76893 6.31812,-17.12889 -3.53612,-6.35997 -13.25754,0.11588 -18.68419,0.47711" />
        <path
           d="m 480.88873,375.80696 c -0.17445,-2.5519 -1.82622,-3.75725 -3.07623,-3.75725" />
        <path
           d="m 474.95535,369.05863 c 2.8125,0 2.85715,2.99108 2.85715,2.99108" />
        <path
           d="m 474.95535,365.97827 c 1.38393,0 1.62187,3.53999 1.62187,3.53999" />
        <path
           d="m 477.8125,375.13006 c 2.45535,2.05357 1.33928,17.94642 1.33928,17.94642" />
        <path
           d="m 490.17857,393.07649 c 3.238,-5.39327 7.19177,-10.60306 4.53241,-15.65568 -2.65937,-5.05261 -6.69504,-0.5984 -16.89848,-0.9961" />
        <path
           d="m 459.73242,393.07617 12.36579,3.4e-4" />
        <path
           d="m 477.8125,393.07651 12.36523,-3.4e-4 0,1.60742 -30.44531,0 -2.8e-4,-1.6071" />
        <path
           style="color:#000000;display:inline;overflow:visible;visibility:visible;fill:none;fill-opacity:1;fill-rule:nonzero;marker:none;enable-background:accumulate" />
        <g>
          <path
             d="m 460.54324,388.10699 c -0.51104,0.0503 -1.06458,0.18475 -1.24062,0.8286 -0.12941,0.43081 0.20432,1.08402 0.52937,1.50525 0.31041,0.39293 0.65674,0.73707 1.00072,1.01182 0.14303,0.0859 0.24132,-0.10485 0.0917,-0.29396 -0.20097,-0.42967 -0.0138,-0.72389 0.1982,-0.80449 0.44664,-0.16684 1.02607,-0.0163 1.58419,0.32356 0.31962,0.22267 0.65092,0.52136 0.90438,0.93706 0.31237,0 0.62474,0 0.9371,0 -0.32385,-0.76195 -0.73427,-1.50378 -1.20777,-2.14725 -0.6616,-0.85877 -1.46015,-1.1868 -2.14688,-1.31599 -0.22441,-0.0439 -0.43852,-0.0466 -0.65037,-0.0446 z" />
          <path
             d="m 467.05095,388.10699 c -0.69553,0.0357 -1.38383,0.26891 -1.68449,1.04021 -0.16353,0.57386 -0.14447,1.30706 -0.055,2.04728 0.0437,0.19464 0.0207,0.51938 0.2096,0.42029 0.26473,0 0.52947,0 0.79421,0 0.0272,-0.87905 0.57544,-1.2603 1.15938,-1.31913 0.32639,-0.0304 0.7594,-0.003 1.10886,0.48073 0.14045,0.19449 0.11854,0.4212 0.21544,0.62276 0.25073,0.2188 0.3101,-0.15366 0.40024,-0.31012 0.15571,-0.4249 0.33069,-0.9309 0.12033,-1.5889 -0.20535,-0.63678 -0.72697,-0.98826 -1.12419,-1.16784 -0.39916,-0.17643 -0.78465,-0.23495 -1.14435,-0.22528 z" />
          <path
             d="m 462.44276,383.25309 c -0.18841,-0.008 -0.0526,0.37265 -0.15157,0.4983 -0.21898,0.74843 -0.68492,1.19592 -1.04125,1.77267 -0.22982,0.40095 -0.2044,1.18554 0.20918,1.81819 0.37626,0.70828 0.95487,0.96313 1.40833,1.51629 0.48053,0.49396 0.89258,1.14255 1.2328,1.81858 0.16252,0.29982 0.30232,0.61878 0.41371,0.93764 0.30231,0 0.60462,0 0.90692,0 -0.19554,-0.81156 -0.23847,-1.60337 -0.14643,-2.27507 0.093,-0.49914 0.26373,-0.91909 0.48231,-1.27975 0.20716,-0.41661 0.20185,-1.15125 -0.17096,-1.799 -0.44895,-0.79483 -1.09764,-1.0868 -1.65512,-1.55399 -0.4377,-0.36712 -0.90178,-0.7239 -1.28492,-1.26174 -0.0329,-0.13095 -0.13089,-0.18186 -0.203,-0.19212 z" />
          <path
             d="m 466.07861,391.61446 c 0.26187,0.003 0.63803,0.11952 0.8632,0.54131 0.16262,0.38155 -0.0596,0.59856 -0.24373,0.66789 -0.39915,0.0863 -0.85345,0.0176 -1.27539,0.0396 -0.48237,-0.019 -0.94499,0.0397 -1.4409,-0.0324 -0.22922,-0.0662 -0.59796,-0.28488 -0.66526,-0.68706 -0.0171,-0.486 0.36273,-0.549 0.66538,-0.52942 0.6989,4e-5 1.39783,-6e-5 2.0967,5e-5 z" />
        </g>
        <g>
          <path
             d="m 489.36747,388.10699 c 0.51104,0.0503 1.06458,0.18475 1.24062,0.8286 0.12941,0.43081 -0.20432,1.08402 -0.52937,1.50525 -0.31041,0.39293 -0.65674,0.73707 -1.00072,1.01182 -0.14303,0.0859 -0.24132,-0.10485 -0.0917,-0.29396 0.20097,-0.42967 0.0138,-0.72389 -0.1982,-0.80449 -0.44664,-0.16684 -1.02607,-0.0163 -1.58419,0.32356 -0.31962,0.22267 -0.65092,0.52136 -0.90438,0.93706 -0.31237,0 -0.62474,0 -0.9371,0 0.32385,-0.76195 0.73427,-1.50378 1.20777,-2.14725 0.6616,-0.85877 1.46015,-1.1868 2.14688,-1.31599 0.22441,-0.0439 0.43852,-0.0466 0.65037,-0.0446 z" />
          <path
             d="m 482.85976,388.10699 c 0.69553,0.0357 1.38383,0.26891 1.68449,1.04021 0.16353,0.57386 0.14447,1.30706 0.055,2.04728 -0.0437,0.19464 -0.0207,0.51938 -0.2096,0.42029 -0.26473,0 -0.52947,0 -0.79421,0 -0.0272,-0.87905 -0.57544,-1.2603 -1.15938,-1.31913 -0.32639,-0.0304 -0.7594,-0.003 -1.10886,0.48073 -0.14045,0.19449 -0.11854,0.4212 -0.21544,0.62276 -0.25073,0.2188 -0.3101,-0.15366 -0.40024,-0.31012 -0.15571,-0.4249 -0.33069,-0.9309 -0.12033,-1.5889 0.20535,-0.63678 0.72697,-0.98826 1.12419,-1.16784 0.39916,-0.17643 0.78465,-0.23495 1.14435,-0.22528 z" />
          <path
             d="m 487.46795,383.25309 c 0.18841,-0.008 0.0526,0.37265 0.15157,0.4983 0.21898,0.74843 0.68492,1.19592 1.04125,1.77267 0.22982,0.40095 0.2044,1.18554 -0.20918,1.81819 -0.37626,0.70828 -0.95487,0.96313 -1.40833,1.51629 -0.48053,0.49396 -0.89258,1.14255 -1.2328,1.81858 -0.16252,0.29982 -0.30232,0.61878 -0.41371,0.93764 -0.30231,0 -0.60462,0 -0.90692,0 0.19554,-0.81156 0.23847,-1.60337 0.14643,-2.27507 -0.093,-0.49914 -0.26373,-0.91909 -0.48231,-1.27975 -0.20716,-0.41661 -0.20185,-1.15125 0.17096,-1.799 0.44895,-0.79483 1.09764,-1.0868 1.65512,-1.55399 0.4377,-0.36712 0.90178,-0.7239 1.28492,-1.26174 0.0329,-0.13095 0.13089,-0.18186 0.203,-0.19212 z" />
          <path
             d="m 483.8321,391.61446 c -0.26187,0.003 -0.63803,0.11952 -0.8632,0.54131 -0.16262,0.38155 0.0596,0.59856 0.24373,0.66789 0.39915,0.0863 0.85345,0.0176 1.27539,0.0396 0.48237,-0.019 0.94499,0.0397 1.4409,-0.0324 0.22922,-0.0662 0.59796,-0.28488 0.66526,-0.68706 0.0171,-0.486 -0.36273,-0.549 -0.66538,-0.52942 -0.6989,4e-5 -1.39783,-6e-5 -2.0967,5e-5 z" />
        </g>
      </g>
      </g>
    </symbol>
    <symbol id="fleet_e" viewbox="-13.5 -13.5 27 27">
    <g transform="translate(#{Ribbon::WIDTH*Ribbon::SCALE/2},#{Ribbon::HEIGHT*Ribbon::SCALE/2}) scale(#{Ribbon::SCALE})">
    <path
         id="path19720"
         d="m -2.453125,-2.734375 0.1035156,0.203125 c 0.00672,0.015244 0.017567,0.03571 0.027344,0.046875 l -0.019531,-0.029297 c 0.044723,0.089446 0.08131,0.194338 0.1074219,0.3144531 0.023614,0.1039025 0.039063,0.2883356 0.039063,0.5371094 v 3.5722656 c 0,0.2487738 -0.014899,0.4337661 -0.039063,0.5449219 -0.025664,0.1129197 -0.061124,0.2132526 -0.1054688,0.3027344 -5.992e-4,0.00121 -0.00135,0.0027 -0.00195,0.00391 l -0.2226562,0.2207031 h 0.3496093 4.3339844 0.5664063 L 2.9433594,1.5488281 2.6875,1.6757812 H 2.662109 l -0.023437,0.00781 c -0.087904,0.031024 -0.1971793,0.06061 -0.328125,0.087891 -0.1167427,0.020029 -0.2804003,0.03125 -0.4882813,0.03125 H 0.15234375 V 0.62890625 H 1.484375 c 0.214103,0 0.3804858,0.0143665 0.4941406,0.0390625 h 0.00391 l 0.00391,0.001953 c 0.1298241,0.0216376 0.2413095,0.0472331 0.3339844,0.078125 l 0.021484,0.007813 h 0.00586 l 0.017578,0.007813 H 2.380867 L 2.5742188,0.859375 V -0.78125 l -0.2089844,0.10351562 h -0.023437 l -0.021484,0.007813 c -0.094908,0.0316352 -0.208515,0.0605307 -0.3398437,0.0878906 -0.1164583,0.0199778 -0.2824604,0.03125 -0.4960938,0.03125 H 0.15234375 V -1.5546875 H 1.6953125 c 0.2198981,0 0.3906771,0.014448 0.5039063,0.039063 h 0.00391 0.00391 c 0.1298241,0.021638 0.2413095,0.049186 0.3339844,0.080078 l 0.021484,0.00781 h 0.00781 l 0.015625,0.00781 h 0.015625 L 2.8359375,-1.3027344 2.6035156,-2.734375 H 2.4746094 -1.859375 Z"
         style="stroke:none;" />
      <path
         id="use15121"
         d="m -2.0253906,-2.453125 h 0.1660156 4.2226562 l 0.1171876,0.7148438 c -0.074194,-0.018999 -0.1429539,-0.040427 -0.2285157,-0.054688 -0.1454581,-0.030901 -0.3281695,-0.044922 -0.5566406,-0.044922 h -1.82617188 v 1.56835935 H 1.484375 c 0.2249577,0 0.405741,-0.0102713 0.5488281,-0.0351563 h 0.00195 0.00195 c 0.095013,-0.0197943 0.1735161,-0.0434712 0.2539062,-0.0664063 V 0.45117188 C 2.2108973,0.42955431 2.132923,0.40840689 2.0390625,0.39257812 1.8930727,0.3608561 1.7105386,0.34570312 1.484375,0.34570312 H -0.13085938 V 2.0859375 H 0.01171875 1.8222656 c 0.2194408,0 0.3982702,-0.012285 0.5410156,-0.037109 h 0.00195 0.00195 c 0.079669,-0.016598 0.1411576,-0.037766 0.2089844,-0.056641 L 2.4492188,2.7011719 H 2.1191406 -2.0234375 c 0.021446,-0.061424 0.049333,-0.1170652 0.064453,-0.1835938 v -0.00195 c 0.03228,-0.14849 0.044922,-0.3462425 0.044922,-0.6054688 v -3.5722656 c 0,-0.2583867 -0.012326,-0.4533455 -0.044922,-0.5976562 v -0.00195 c -0.015318,-0.070137 -0.044519,-0.1277092 -0.066406,-0.1914062 z"
         style="fill:url(#linearGradient20073);fill-opacity:1;fill-rule:nonzero;stroke:none;" />
      <path
         style="color:#000000;fill:url(#linearGradient23183);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="M 2.9431845,1.5487874 2.5762818,1.9921711 2.4491577,2.7011719 2.6858357,2.9822917 Z"
         id="path20455"/>
      <path
         style="color:#000000;fill:url(#linearGradient20531);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="M 0.15214047,1.8025187 -0.13104651,2.0857056 H 0.01158058 1.8223227 c 0.2194402,0 0.3983067,-0.011866 0.541052,-0.03669 h 0.00207 0.00155 C 2.4466611,2.0324172 2.508455,2.0110462 2.5762818,1.9921711 L 2.9431845,1.5487874 2.6873861,1.6759114 h -0.025321 l -0.023255,0.00775 c -0.087904,0.031024 -0.1971995,0.060569 -0.3281452,0.08785 -0.1167429,0.020029 -0.280462,0.031006 -0.4883423,0.031006 z"
         id="path20487" />
      <path
         style="color:#000000;fill:url(#linearGradient23803);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="M -0.13104651,0.34576008 V 2.0857056 L 0.15214047,1.8025187 V 0.62894693 Z"
         id="path20485" />
      <path
         style="color:#000000;fill:url(#linearGradient20523);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="M -0.13104651,0.34576008 0.15214047,0.62894693 H 1.4843588 c 0.214103,0 0.3803719,0.0140603 0.4940266,0.0387573 h 0.00413 l 0.00362,0.002067 c 0.1298241,0.021638 0.2416717,0.0471395 0.3343465,0.0780314 l 0.021187,0.007751 h 0.0062 l 0.01757,0.008268 h 0.015503 L 2.5742146,0.8594238 2.2910279,0.45118 C 2.2109157,0.4295624 2.1327073,0.40861444 2.0388469,0.39278564 1.892857,0.36106363 1.7105223,0.34576008 1.4843588,0.34576008 Z"
         id="path20453" />
      <path
         style="color:#000000;fill:url(#linearGradient24667);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="M 2.5742146,-0.78130289 2.2910279,-0.37099203 V 0.45118 l 0.2831867,0.4082438 z"
         id="path20451" />
      <path
         style="color:#000000;fill:url(#linearGradient21677);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="m 0.15214047,-0.55082601 -0.28318698,0.28111978 H 1.4843588 c 0.2249578,0 0.4057169,-0.010255 0.5488035,-0.03514 h 0.00207 0.00207 c 0.095013,-0.0197943 0.173341,-0.0432107 0.2537312,-0.0661458 l 0.2831867,-0.41031086 -0.2087727,0.10335286 h -0.023771 l -0.021187,0.007751 c -0.094908,0.0316352 -0.2087023,0.0610068 -0.3400308,0.0883667 -0.1164585,0.0199778 -0.2824605,0.0310059 -0.4960938,0.0310059 z"
         id="path20478" />
      <path
         style="color:#000000;fill:url(#linearGradient20511);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="m -0.13104651,-1.8380859 v 1.56837967 L 0.15214047,-0.55082601 V -1.5548991 Z"
         id="path20476" />
      <path
         style="color:#000000;fill:url(#linearGradient20507);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="m -0.13104651,-1.8380859 0.28318698,0.2831868 H 1.6951987 c 0.2198981,0 0.390616,0.014659 0.5038452,0.039274 h 0.00413 0.00413 c 0.1298239,0.021638 0.2411548,0.049206 0.3338296,0.080099 l 0.021187,0.00775 h 0.00827 l 0.015503,0.00775 h 0.015503 L 2.8362076,-1.3027206 2.4806737,-1.7383529 C 2.4064797,-1.7573519 2.337309,-1.7788689 2.251747,-1.7931299 2.1062888,-1.8240309 1.9236631,-1.8380889 1.695192,-1.8380889 Z"
         id="path20449" />
      <path
         style="color:#000000;fill:url(#linearGradient20503);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="m -2.0234375,2.7011719 -0.5410523,0.2811198 h 0.3498496 4.3335855 0.5668904 L 2.4491577,2.7011719 H 2.1189453 Z"
         id="path20464" />
      <path
         style="color:#000000;fill:url(#linearGradient22583);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="m -2.4528687,-2.734672 0.1033529,0.2036051 c 0.00672,0.015244 0.017612,0.035344 0.027389,0.046509 l -0.019637,-0.028939 c 0.044723,0.089446 0.081375,0.1940776 0.107487,0.3141927 0.023614,0.1039025 0.038757,0.2881443 0.038757,0.5369181 v 3.5723918 c 0,0.2487738 -0.014593,0.4340306 -0.038757,0.5451863 -0.025664,0.1129196 -0.061075,0.2133425 -0.1054198,0.3028238 -5.993e-4,0.00121 -0.00147,0.00241 -0.00207,0.00362 l -0.2227255,0.2206585 0.5410523,-0.2811198 c 0.021446,-0.061424 0.049476,-0.1169228 0.064596,-0.1834515 v -0.00207 c 0.03228,-0.14849 0.044959,-0.3464216 0.044959,-0.6056478 v -3.5723918 c 0,-0.2583866 -0.012363,-0.4530688 -0.044959,-0.5973795 v -0.00207 c -0.015318,-0.070137 -0.044776,-0.1275058 -0.066663,-0.1912028 z"
         id="path20462" />
      <path
         style="color:#000000;fill:url(#linearGradient20495);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="m -2.4528687,-2.734672 0.4273643,0.2816365 h 0.166398 4.2224811 L 2.6036701,-2.734672 h -0.129191 -4.3335855 z"
         id="path20447" />
      <path
         style="color:#000000;fill:url(#linearGradient24001);fill-opacity:1;fill-rule:nonzero;stroke:none;"
         d="m 2.6036701,-2.734672 -0.2402954,0.2816365 0.1173057,0.7146851 0.3555339,0.4356323 z"
         id="path19738" /></g></symbol>

    <linearGradient
       id="linearGradient19775">
      <stop
         id="stop19761"
         offset="0"
         style="stop-color:#000000;stop-opacity:0.54966885" />
      <stop
         style="stop-color:#000000;stop-opacity:0.01986755"
         offset="0.32931894"
         id="stop19763" />
      <stop
         id="stop19765"
         offset="0.41046107"
         style="stop-color:#fdfdfd;stop-opacity:0" />
      <stop
         style="stop-color:#fff5f5;stop-opacity:0.22847682"
         offset="0.49270236"
         id="stop19767" />
      <stop
         id="stop19769"
         offset="0.54687983"
         style="stop-color:#fdfdfd;stop-opacity:0" />
      <stop
         id="stop19771"
         offset="0.67283714"
         style="stop-color:#000000;stop-opacity:0.05298013" />
      <stop
         id="stop19773"
         offset="1"
         style="stop-color:#000000;stop-opacity:0.68211919" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient19759-1"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(1.0666667,0,0,1.0666667,0.03200016,0.06400009)"
       x1="8.3438311"
       y1="-8.7521744"
       x2="-7.1996603"
       y2="9.5110817" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient20073"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846668,0.01693325)"
       x1="-13.21417"
       y1="-14.457779"
       x2="7.9680099"
       y2="17.396509" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient20495"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="4.9119115"
       y1="-7.7477102"
       x2="-3.8514462"
       y2="6.0791621" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient20503"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="4.9119115"
       y1="-7.7477102"
       x2="-3.8514462"
       y2="6.0791621" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient20507"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="4.9119115"
       y1="-7.7477102"
       x2="-3.8514462"
       y2="6.0791621" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient20511"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="4.9119115"
       y1="-7.7477102"
       x2="-3.8514462"
       y2="6.0791621" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient20523"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="4.9119115"
       y1="-7.7477102"
       x2="-3.8514462"
       y2="6.0791621" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient20531"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="4.9119115"
       y1="-7.7477102"
       x2="-3.8514462"
       y2="6.0791621" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient21677"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="2.8611305"
       y1="-11.179629"
       x2="2.8449821"
       y2="2.8146532" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient22583"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="4.325974"
       y1="-2.5579782"
       x2="-8.9993258"
       y2="15.705278" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient23183"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="4.9119115"
       y1="-7.7477102"
       x2="-1.4658436"
       y2="6.7906575" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient23803"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="-0.49433804"
       y1="-1.0156516"
       x2="-8.790062"
       y2="12.650032" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient24001"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="-5.5512581"
       y1="-8.6266165"
       x2="-3.8514462"
       y2="6.0791621" />
    <linearGradient
       xlink:href="#linearGradient19775"
       id="linearGradient24667"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(0.28222223,0,0,0.28222223,0.00846667,0.01693324)"
       x1="-0.86375803"
       y1="-12.477063"
       x2="-4.2699728"
       y2="0.84757745" />
    <linearGradient
       gradientTransform="translate(0,-1.158807e-6)"
       gradientUnits="userSpaceOnUse"
       y2="38.745022"
       x2="93.147804"
       y1="-6.5340118"
       x1="94.772163"
       id="linearGradient16887"
       xlink:href="#linearGradient16885" />
    <linearGradient
       id="linearGradient16885">
      <stop
         id="stop16881"
         offset="0"
         style="stop-color:#000000;stop-opacity:0.33112583" />
      <stop
         style="stop-color:#000000;stop-opacity:0"
         offset="0.33897775"
         id="stop28001" />
      <stop
         id="stop35925"
         offset="0.36459827"
         style="stop-color:#ffffff;stop-opacity:0" />
      <stop
         style="stop-color:#ffffff;stop-opacity:0.6754967"
         offset="0.46235177"
         id="stop41113" />
      <stop
         style="stop-color:#ffffff;stop-opacity:0"
         offset="0.57014531"
         id="stop38807" />
      <stop
         id="stop30019"
         offset="0.5923484"
         style="stop-color:#000000;stop-opacity:0" />
      <stop
         id="stop16883"
         offset="1"
         style="stop-color:#000000;stop-opacity:0.21568628" />
    </linearGradient>
    <linearGradient
       gradientTransform="translate(0,-1.158807e-6)"
       gradientUnits="userSpaceOnUse"
       y2="38.514057"
       x2="-5.8680582"
       y1="26.158653"
       x1="118.32211"
       id="linearGradient17033"
       xlink:href="#linearGradient16885" />
    <linearGradient
       gradientTransform="translate(0,-1.158807e-6)"
       gradientUnits="userSpaceOnUse"
       y2="36.599201"
       x2="4.5952058"
       y1="-13.844843"
       x1="1.2102576"
       id="linearGradient17179"
       xlink:href="#linearGradient16885" />
    <linearGradient
       gradientTransform="translate(0,-1.158807e-6)"
       gradientUnits="userSpaceOnUse"
       y2="2.2246094"
       x2="105"
       y1="2.2246094"
       x1="0"
       id="linearGradient17325"
       xlink:href="#linearGradient64025" />
    <linearGradient
       id="linearGradient64025">
      <stop
         style="stop-color:#000000;stop-opacity:0.33112583"
         offset="0"
         id="stop64011" />
      <stop
         id="stop64013"
         offset="0.33897775"
         style="stop-color:#000000;stop-opacity:0" />
      <stop
         style="stop-color:#ffffff;stop-opacity:0"
         offset="0.36459827"
         id="stop64015" />
      <stop
         id="stop64017"
         offset="0.46235177"
         style="stop-color:#ffffff;stop-opacity:0.6754967" />
      <stop
         id="stop64019"
         offset="0.57014531"
         style="stop-color:#ffffff;stop-opacity:0" />
      <stop
         style="stop-color:#000000;stop-opacity:0"
         offset="1"
         id="stop64021" />
      <stop
         style="stop-color:#000000;stop-opacity:0.21568628"
         offset="1"
         id="stop64023" />
    </linearGradient>
<symbol id="unitFrame">
  <g
     transform="scale(3.79) translate(0,-289.85625)"
     id="layer1">
    <g
       transform="matrix(0.26458333,0,0,0.26458333,0,289.85625)"
       id="g116599">
      <path
         style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:4.9000001;stroke-linecap:square;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate"
         d="M 0,0 V 27 H 105 V 0 Z M 4.4492188,4.4492188 H 100.55078 V 22.550781 H 4.4492188 Z"
         id="path11500" />
      <g
         id="g113423">
        <path
           id="path14993"
           d="M 100.55078,22.550781 105,27 V 0 l -4.44922,4.4492188 z"
           style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;fill:url(#linearGradient16887);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:4.9000001;stroke-linecap:square;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
        <path
           id="path14991"
           d="M 4.4492188,22.550781 0,27 h 105 l -4.44922,-4.449219 z"
           style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;fill:url(#linearGradient17033);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:4.9000001;stroke-linecap:square;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
        <path
           id="path14989"
           d="M 0,0 V 27 L 4.4492188,22.550781 V 4.4492188 Z"
           style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;fill:url(#linearGradient17179);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:4.9000001;stroke-linecap:square;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
        <path
           id="path14410"
           d="M 0,0 4.4492188,4.4492188 H 100.55078 L 105,0 Z"
           style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;fill:url(#linearGradient17325);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:4.9000001;stroke-linecap:square;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
      </g>
    </g>
  </g>
</symbol>
    <symbol
       id="star_laurel"
       viewbox="-18 -13.5 36 27">
                  <g transform="translate(#{Ribbon::WIDTH*Ribbon::SCALE/2},#{Ribbon::HEIGHT*Ribbon::SCALE/2})">

      <g
         id="half_laurel">
        <use
           transform="matrix(-0.82818821,-0.56045006,-0.56045006,0.82818821,16.402592,-13.505225)"
           xlink:href="#leaf"/>
        <use
           xlink:href="#leaf"
           transform="matrix(-0.30901699,-0.95105651,0.95105651,-0.30901699,0.00259133,-3.0298691e-4)" />
        <use
           xlink:href="#leaf"
           transform="matrix(-0.95756323,-0.28822324,-0.28822324,0.95756323,15.324961,-14.459868)" />
        <use
           transform="matrix(-0.10452846,-0.99452189,0.99452189,-0.10452846,0.00239636,-2.8023511e-5)"
           xlink:href="#leaf" />
        <use
           transform="matrix(-0.8767132,-0.48101346,-0.48101346,0.8767132,17.99651,-10.957902)"
           xlink:href="#leaf" />
        <use
           xlink:href="#leaf"
           transform="matrix(0.10452847,-0.99452189,0.99452189,0.10452847,0.00214847,2.0039009e-4)" />
        <use
           xlink:href="#leaf"
           transform="matrix(-0.75754659,-0.65278109,-0.65278109,0.75754659,19.881579,-6.9770166)" />
        <use
           transform="matrix(0.309017,-0.95105651,0.95105651,0.309017,0.00185852,3.7218145e-4)"
           xlink:href="#leaf" />
        <use
           transform="matrix(-0.60527156,-0.79601905,-0.79601905,0.60527156,20.897782,-2.6911948)"
           xlink:href="#leaf" />
        <use
           xlink:href="#leaf"
           transform="matrix(0.5,-0.8660254,0.8660254,0.5,0.00153918,4.7996799e-4)" />
        <use
           xlink:href="#leaf"
           transform="matrix(-0.42654326,-0.90446716,-0.90446716,0.42654326,21.000706,1.712252)" />
        <use
           transform="matrix(0.66913061,-0.74314482,0.74314482,0.66913061,0.0012044,5.1908716e-4)"
           xlink:href="#leaf" />
        <use
           transform="matrix(-0.22917297,-0.97338571,-0.97338571,0.22917297,20.185853,6.0408721)"
           xlink:href="#leaf" />
        <use
           xlink:href="#leaf"
           transform="matrix(0.809017,-0.58778525,0.58778525,0.809017,8.6879861e-4,4.87816e-4)" />
        <use
           xlink:href="#leaf"
           transform="matrix(-0.02178672,-0.99976264,-0.99976264,0.02178672,18.488836,10.105484)" />
        <use
           transform="matrix(0.91354546,-0.40673664,0.40673664,0.91354546,5.47033e-4,3.8750531e-4)"
           xlink:href="#leaf" />
        <use
           transform="matrix(0.18655171,-0.98244514,-0.98244514,-0.18655171,15.983822,13.728445)"
           xlink:href="#leaf" />
        <use
           xlink:href="#leaf"
           transform="matrix(0.9781476,-0.20791169,0.20791169,0.9781476,2.5314851e-4,2.2249581e-4)" />
        <use
           xlink:href="#leaf"
           transform="matrix(0.38673694,-0.92219007,-0.92219007,-0.38673694,12.780293,16.751414)" />
        <g
           id="leaf"
           transform="matrix(-0.07000159,0.77520757,-0.77520757,-0.07000159,17.755421,23.172755)">
          <path
             style="stroke:none"
             d="m -14.359906,16.558932 c 0,1.565629 -0.464903,2.203477 -1.206015,2.203476 -0.741112,0 -1.206014,-0.637847 -1.206014,-2.203476 0,-1.565628 0.938411,-3.466166 1.206014,-3.466166 0.267603,-10e-7 1.206015,1.900537 1.206015,3.466166 z"/>
          <path
             style="opacity:0.384;fill:white;stroke:none;"
             d="m -15.717927,16.180283 c 0,1.565629 0.166321,1.989911 -0.238101,2.009391 -0.404423,0.01948 -0.652054,-0.06566 -0.652054,-1.631286 0,-1.565628 0.725796,-3.341593 1.075109,-3.217958 0.127604,0.04516 0.340772,0.360163 0.0982,0.516782 -0.426286,0.275239 -0.283157,1.329364 -0.283157,2.323071 z" />
          <path
             d="m -14.438852,16.840784 c 0,1.565629 -0.85512,2.061991 -1.476488,1.687866 -0.621369,-0.374126 0.757376,-0.08207 0.757376,-1.647701 0,-1.565628 -0.213152,-3.318828 -0.06267,-3.037457 0.150487,0.28137 0.781777,1.431663 0.781782,2.997292 z"
             style="fill: black; opacity:0.24299999;stroke:none;" />
          <path
             d="m -14.359906,16.558932 c 0,1.565629 -0.464903,2.203477 -1.206015,2.203476 -0.741112,0 -1.206014,-0.637847 -1.206014,-2.203476 0,-1.565628 0.938411,-3.466166 1.206014,-3.466166 0.267603,-10e-7 1.206015,1.900537 1.206015,3.466166 z"
             style="fill:none;" />
        </g>
      </g>
      <use
         transform="matrix(-1,0,0,1,0,0)"
         xlink:href="#half_laurel" />
      <g>
        <path
           style="stroke: none;"
           d="m 0.00124526,-9.8799597 2.41080364,3.2564908 3.940014,-0.944982 -0.2464492,4.0442513 3.6256485,1.808694 L 6.9428765,1.2241562 8.5576784,4.9402181 4.5320729,5.3997899 3.3804443,9.2844331 0.00124446,7.0488762 -3.3779547,9.2844329 -4.5295837,5.3997892 -8.5551886,4.9402177 l 1.6148019,-3.7160626 -2.7883854,-2.9396612 3.625649,-1.8086944 -0.2464494,-4.0442507 3.9400146,0.9449819 z" />
        <g style="stroke: none;"
           transform="translate(-52.499607,-13.500763)">
          <path
             d="M 46.148438,5.9316406 52.5,13.5 50.089844,6.8769531 46.148438,5.9316406 Z M 52.5,13.5 58.851562,5.9316406 54.910156,6.8769531 52.5,13.5 Z"
             style="fill:#ffffff;fill-opacity:0.71142859;" />
          <path
             d="M 46.396484,9.9765625 42.769531,11.785156 52.5,13.5 46.396484,9.9765625 Z M 52.5,13.5 62.230469,11.785156 58.603516,9.9765625 52.5,13.5 Z"
             style="fill:#ffffff;fill-opacity:0.50571445;" />
          <path
             d="M 52.5,13.5 61.056641,18.439453 59.441406,14.724609 52.5,13.5 Z m 0,0 -6.941406,1.224609 -1.615235,3.714844 L 52.5,13.5 Z"
             style="fill:#ffffff;fill-opacity:0.15142858;" />
          <path
             d="M 52.5,13.5 55.878906,22.785156 57.03125,18.900391 52.5,13.5 Z m 0,0 -4.53125,5.400391 1.152344,3.884765 L 52.5,13.5 Z"
             style="fill:#000000;fill-opacity:0.27428571;" />
          <path
             d="M 52.5,13.5 49.121094,22.785156 52.5,20.548828 55.878906,22.785156 52.5,13.5 Z"
             style="fill:#000000;fill-opacity:0.61142853;" />
          <path
             d="m 52.5,13.5 4.53125,5.400391 4.025391,-0.460938 L 52.5,13.5 Z m 0,0 -8.556641,4.939453 4.025391,0.460938 L 52.5,13.5 Z"
             style="fill:#000000;fill-opacity:0.54857142;" />
          <path
             d="M 42.769531,11.785156 45.558594,14.724609 52.5,13.5 42.769531,11.785156 Z M 52.5,13.5 59.441406,14.724609 62.230469,11.785156 52.5,13.5 Z"
             style="fill:#000000;fill-opacity:0.34285715;" />
          <path
             d="M 46.148438,5.9316406 46.396484,9.9765625 52.5,13.5 46.148438,5.9316406 Z M 52.5,13.5 58.603516,9.9765625 58.851562,5.9316406 52.5,13.5 Z"
             style="fill:#000000;fill-opacity:0.07142855;" />
          <path
             d="M 52.5,3.6191406 50.089844,6.8769531 52.5,13.5 54.910156,6.8769531 52.5,3.6191406 Z"
             style="fill:#ffffff;fill-opacity:0.40285716;" />
        </g>
        <g
	   style="fill:none;"
           transform="translate(-52.498755,-13.499868)">
          <path
             d="m 52.5,3.6199083 2.410804,3.2564908 3.940014,-0.944982 -0.246449,4.0442513 3.625648,1.8086936 -2.788385,2.939662 1.614801,3.716062 -4.025605,0.459572 -1.151629,3.884643 -3.3792,-2.235557 -3.379199,2.235557 -1.151629,-3.884644 -4.025605,-0.459571 1.614802,-3.716063 -2.788385,-2.939661 3.625649,-1.8086945 -0.246449,-4.0442507 3.940014,0.9449819 z" />
          <path
             d="m 52.5,3.6199083 -8.52e-4,9.8791967" />
          <path
             d="M 54.909304,6.8760584 52.5,13.500027" />
          <path
             d="m 46.149182,5.931417 6.349573,7.568451" />
          <path
             d="M 50.087829,6.8771019 52.5,13.500027" />
          <path
             d="m 42.769982,11.784362 9.728962,1.716343" />
          <path
             d="M 46.395036,9.9770856 52.5,13.500027" />
          <path
             d="m 43.943566,18.440086 8.556061,-4.938861" />
          <path
             d="M 45.558823,14.725493 52.5,13.500027" />
          <path
             d="m 49.1208,22.784302 3.379684,-9.283118" />
          <path
             d="M 47.970464,18.900491 52.5,13.500027" />
          <path
             d="m 55.8792,22.784302 -3.378086,-9.2837" />
          <path
             d="M 52.501526,20.548552 52.5,13.500027" />
          <path
             d="M 61.056434,18.440086 52.501223,13.499751" />
          <path
             d="M 57.031874,18.898529 52.5,13.500027" />
          <path
             d="m 62.230017,11.784362 -9.729258,1.714667" />
          <path
             d="M 59.441707,14.722487 52.5,13.500027" />
          <path
             d="M 58.850817,5.931417 52.49994,13.498775" />
          <path
             d="M 58.603438,9.9744424 52.5,13.500027" />
        </g>
      </g>
      </g>
    </symbol>
    <linearGradient
       id="linearGradient25712">
      <stop
         id="stop25708"
         offset="0"
         style="stop-color:#ffffff;stop-opacity:0" />
      <stop
         id="stop25710"
         offset="1"
         style="stop-color:#000000;stop-opacity:0.39714867" />
    </linearGradient>
    <radialGradient
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(2.38735,1.7390231,-1.9584346,2.6885557,123.63807,-27.367896)"
       r="24.809998"
       fy="69.052635"
       fx="97.415215"
       cy="69.052643"
       cx="97.41523"
       id="radialGradient25706-9"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="71.286072"
       fx="74.334244"
       cy="71.286079"
       cx="74.334259"
       gradientTransform="matrix(0.13116253,0.21029038,-0.10220466,0.06374718,159.02716,273.39502)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26143-9"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="67.350838"
       fx="76.166801"
       cy="67.350845"
       cx="76.166817"
       gradientTransform="matrix(0.09240805,0.19151758,-0.09296856,0.04485774,172.80285,268.56462)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26231-9"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="67.350838"
       fx="76.166801"
       cy="67.350845"
       cx="76.166817"
       gradientTransform="matrix(0.09240805,0.19151758,-0.09296856,0.04485774,172.80285,268.56462)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26231-0"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="67.350838"
       fx="76.166801"
       cy="67.350845"
       cx="76.166817"
       gradientTransform="matrix(0.09240805,0.19151758,-0.09296856,0.04485774,172.80285,268.56462)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26231-08"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="69.052635"
       fx="97.415215"
       cy="69.052643"
       cx="97.41523"
       gradientTransform="matrix(0.63165301,0.46011652,-0.51816915,0.71134702,26.164469,-16.595522)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26504"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="48.088383"
       fx="102.50529"
       cy="48.08839"
       cx="102.5053"
       gradientTransform="matrix(0.1253465,0.20461072,-0.27336263,0.16746456,66.291532,35.750434)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26506"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="54.671585"
       fx="103.41431"
       cy="54.671593"
       cx="103.41434"
       gradientTransform="matrix(0.21659386,0.11604147,-0.08972401,0.16747173,45.665915,48.723747)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26508"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="-83.997383"
       fx="754.71985"
       cy="-83.997375"
       cx="754.71985"
       gradientTransform="matrix(-0.03410824,0.02344099,-0.01433116,-0.02085282,88.529004,84.113753)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26510"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="61.71143"
       fx="103.2375"
       cy="61.711437"
       cx="103.23751"
       gradientTransform="matrix(0.17030592,0.14702406,-0.12432086,0.14400756,49.487742,50.740088)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26512"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="-3.8190491"
       fx="738.58649"
       cy="-3.8190415"
       cx="738.58649"
       gradientTransform="matrix(-0.04547418,0.01822297,-0.01185507,-0.02958352,94.803916,90.439172)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26514"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="81.128799"
       fx="108.80248"
       cy="81.128807"
       cx="108.8025"
       gradientTransform="matrix(0.62713307,0.46625835,-0.20846856,0.28039699,1.5304131,17.698985)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26516"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="54.728634"
       fx="699.04706"
       cy="54.728642"
       cx="699.04706"
       gradientTransform="matrix(-0.02027554,0.06022093,-0.03020448,-0.01016943,74.133814,61.25822)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26518"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="59.82394"
       fx="670.26099"
       cy="59.823948"
       cx="670.26105"
       gradientTransform="matrix(-0.01874803,0.05640754,-0.03024375,-0.01005204,71.545887,64.076806)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26520"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="61.780548"
       fx="86.062531"
       cy="61.780556"
       cx="86.062546"
       gradientTransform="matrix(0.29253044,0.23303183,-0.2363305,0.29667123,37.938097,28.567283)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26522"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="212.9733"
       fx="584.33826"
       cy="212.9733"
       cx="584.33832"
       gradientTransform="matrix(0.04845202,-0.01002856,0.00645961,0.03120899,20.359113,98.29913)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26524"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="280.95822"
       fx="552.15527"
       cy="280.95822"
       cx="552.15527"
       gradientTransform="matrix(-0.0660906,0.0327316,-0.01414436,-0.02855985,87.558183,88.392843)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26526"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="206.48787"
       fx="482.11655"
       cy="206.48787"
       cx="482.11655"
       gradientTransform="matrix(0.07975529,-0.00163,6.5121219e-4,0.03186383,8.0893378,87.495043)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26528"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="281.2991"
       fx="504.38126"
       cy="281.29913"
       cx="504.38129"
       gradientTransform="matrix(0.06525,-0.029881,0.01326972,0.02897658,8.7810879,102.70967)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26530"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="62.57555"
       fx="79.698227"
       cy="62.575558"
       cx="79.698242"
       gradientTransform="matrix(0.29391056,0.03155716,-0.02087524,0.19442339,21.963505,49.908443)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26532"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="-73.65625"
       fx="29.090296"
       cy="-73.656242"
       cx="29.090311"
       gradientTransform="matrix(0.00485157,0.01878771,-0.01449702,0.00374359,40.48677,62.032388)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26534"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="39.32222"
       fx="81.937317"
       cy="39.322227"
       cx="81.937332"
       gradientTransform="matrix(0.01041084,0.01773718,-0.023554,0.01382502,40.281925,64.32502)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26536"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="69.052635"
       fx="97.415215"
       cy="69.052643"
       cx="97.41523"
       gradientTransform="matrix(0.63165301,0.46011652,-0.51816915,0.71134702,26.164469,-16.595522)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26538"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="67.350838"
       fx="76.166801"
       cy="67.350845"
       cx="76.166817"
       gradientTransform="matrix(0.02444963,0.05067236,-0.02459793,0.01186861,39.172651,61.703292)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26540"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="58.334438"
       fx="1.3470809"
       cy="58.334446"
       cx="1.3470962"
       gradientTransform="matrix(0.01377394,0.02896651,-0.02053309,0.00976374,38.949921,61.855354)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26542"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="79.95681"
       fx="72.369347"
       cy="79.956818"
       cx="72.369362"
       gradientTransform="matrix(0.04475063,0.07515386,-0.01831444,0.0109054,34.454445,61.940329)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26544"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="436.20999"
       fx="353.23297"
       cy="436.21002"
       cx="353.23297"
       gradientTransform="matrix(0.06524666,-0.01766365,0.00832821,0.0307631,9.3102349,82.812475)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26546"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="132.33984"
       fx="42.206841"
       cy="132.33984"
       cx="42.206856"
       gradientTransform="matrix(0.03470342,0.05563933,-0.02704165,0.01686644,35.527832,62.98133)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26548"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="479.49588"
       fx="320.36044"
       cy="479.49591"
       cx="320.36047"
       gradientTransform="matrix(0.06525169,-0.01308201,0.00626489,0.03124866,9.7709243,78.100825)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26550"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="418.00085"
       fx="253.88205"
       cy="418.00085"
       cx="253.88205"
       gradientTransform="matrix(0.06982861,0.00524232,-0.00238594,0.03178105,16.304067,69.541907)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26552"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="231.1375"
       fx="132.14876"
       cy="231.1375"
       cx="132.14879"
       gradientTransform="matrix(0.04276501,0.00916192,-0.00667647,0.03116332,27.877141,64.777923)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26554"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="486.76022"
       fx="277.98184"
       cy="486.76025"
       cx="277.98187"
       gradientTransform="matrix(0.05914029,-0.02682713,0.0131658,0.02902395,9.1633928,79.98776)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26556"
       xlink:href="#linearGradient25712" />
    <radialGradient
       r="24.809998"
       fy="239.93108"
       fx="57.260502"
       cy="239.93109"
       cx="57.260517"
       gradientTransform="matrix(0.03470342,0.05563933,-0.02704165,0.01686644,35.527832,62.98133)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient26558"
       xlink:href="#linearGradient25712" />
<symbol id="manticore">
    <g
       transform="scale(0.5) translate(-7,-75) translate(#{Ribbon::WIDTH/2*Ribbon::SCALE},#{Ribbon::HEIGHT/2*Ribbon::SCALE})"
       id="use26440">
      <path
         style="stroke:none;stroke-width:0.35277775"
         d="m 55.381633,67.85322 c -0.908902,-0.0611 -1.73454,0.822815 -2.652551,0.517282 -0.894049,-0.259408 -1.985431,-0.474956 -2.748153,0.221692 0.472355,-0.11244 0.938477,0.103764 1.166336,0.528135 -0.317685,-0.104302 -0.629761,-0.26732 -0.971518,-0.267169 -0.303435,-0.0726 -0.921301,0.208796 -0.58601,0.562758 0.308867,0.08727 0.556861,0.356749 0.646988,0.663007 -0.231981,-0.0053 -0.575048,0.27315 -0.834056,0.252182 -0.659622,0.24711 -1.561894,-0.153816 -2.031918,0.522965 -0.827315,0.185952 -1.767525,0.129995 -2.615343,0.374655 -0.15857,0.009 -0.24607,0.07766 -0.29714,0.172598 -0.305282,-0.223504 -0.907937,-0.05782 -0.777214,0.440801 0.345549,-0.03447 0.117695,0.558454 0.486791,0.553453 0.01662,0.0026 0.03145,-5.29e-4 0.04754,0 -0.152365,0.282954 -0.105206,0.670825 0.06873,0.943613 0.689806,0.941004 2.032304,0.961937 2.86339,1.733743 -0.171337,0.0029 -0.38703,0.160012 -0.48214,0.300241 -0.157784,-0.0199 -0.269708,0.05147 -0.33383,0.158131 -0.0035,-0.0057 -0.0062,-0.01188 -0.0098,-0.01757 -0.111316,-0.17702 -0.254183,-0.334391 -0.420645,-0.461987 -0.162349,-0.0978 -0.561576,-0.432562 -0.585497,-0.188103 -0.03039,0.375778 -0.09786,0.962301 0.187587,1.243336 -0.103486,-0.0016 -0.211246,-0.0033 -0.309025,-0.0026 0.293449,1.180499 1.443217,2.021239 2.640666,2.060339 0.414038,0.05035 0.464693,-0.437814 0.352433,-0.722952 -1.56e-4,-0.586166 0.615629,-0.749972 1.133782,-0.798402 -0.396024,0.358833 -0.393126,1.091113 -0.02066,1.503786 0.409535,0.23576 0.06213,0.707099 -0.302824,0.7121 -0.586116,-0.10155 -0.646814,0.653409 -1.004591,0.925009 -0.480581,0.241859 -0.45107,-0.49799 -0.788064,-0.651642 -0.425143,0.23704 -0.457917,0.802447 -0.318844,1.217499 0.327914,0.753549 1.061193,1.168686 1.847432,1.25522 -0.288137,0.325509 -0.664766,0.895178 -0.362768,1.298112 -0.361087,0.381873 -0.702426,0.858862 -0.944644,1.37976 -0.624004,-0.610309 -1.419588,-1.010391 -2.048455,-1.615922 -0.842793,-0.631049 -0.551235,-1.968534 -1.457275,-2.543513 0.401019,-0.584182 0.324988,-1.511141 -0.206189,-1.979724 0,0 -5.3e-4,-5.29e-4 -5.3e-4,-5.29e-4 -0.26122,-0.439214 -0.54507,-0.890905 -1.012343,-1.126546 -0.16488,-0.0838 -0.85679,-0.285895 -0.597379,0.0072 0.288547,0.270684 0.168471,0.738745 0.299723,1.024744 -0.278895,0.239078 -0.426249,0.63986 -0.262515,1.007692 -0.442163,-0.05161 -0.545763,-0.509728 -0.563274,-0.896588 -0.01386,-0.471395 -0.330546,-0.920382 -0.746207,-1.114142 -0.22969,-0.506643 -0.744066,-0.860063 -1.286742,-0.945163 -0.192136,-0.01132 -0.752163,-0.08691 -0.597898,0.237712 0.601848,0.194363 0.201488,0.993947 0.578776,1.303279 -0.09457,0.437537 0.08823,0.967521 0.372589,1.303796 -0.206028,0.24947 -0.576149,0.04051 -0.852662,0.06511 -0.257844,-0.08044 -0.535678,-0.03369 -0.777214,0.09147 -0.656389,-0.102042 -1.345956,-0.335994 -1.632458,-0.994254 -0.04475,0.742379 0.06555,1.746922 0.873848,2.043803 0.0452,-0.0011 0.08203,-0.01566 0.115755,-0.03514 0.01037,0.128773 0.04901,0.258305 0.130225,0.382924 0.345276,0.608949 1.115309,0.223477 1.649511,0.338997 0.278659,0.03375 0.349133,0.382273 0.0021,0.378272 -0.43656,0.0063 -0.695129,0.342879 -0.756028,0.725019 -0.527741,0.09121 -1.081291,0.09257 -1.440738,-0.379822 0.200908,0.736192 0.775792,1.559171 1.626258,1.51257 0.179039,0.03492 0.30511,-0.01892 0.360183,-0.105937 0.596657,0.163492 1.122288,-0.484142 1.64383,-0.687813 0.317987,0.0884 0.688919,0.0922 1.036627,0.0832 0.699405,0.597836 0.476173,1.692941 0.167949,2.449462 -0.173302,0.515109 0.502386,0.605457 0.851628,0.661458 0.972262,0.704279 0.796456,2.295409 1.830895,3.002399 0.21735,0.301771 0.707247,0.260557 0.798918,-0.123505 0.486336,0.191239 0.678397,0.778225 1.174607,0.973582 0.161761,1.46852 0.993246,2.868004 2.316136,3.580144 -0.06231,-0.478999 -0.151813,-0.970934 -0.05116,-1.451073 0.08353,0.423198 0.395404,0.951367 0.871781,1.099158 0.400129,-0.04065 0.322635,0.419629 0.312126,0.68833 -0.27686,0.09233 -0.807484,0.03214 -1.18029,0.112138 -1.250942,0.08845 -2.376453,0.85508 -3.640603,0.785482 -0.256019,-0.397002 -0.726858,-0.565706 -1.163754,-0.676445 -0.836732,-0.06005 -1.348624,-0.869942 -2.18643,-0.929142 -0.512717,-0.100579 -1.174234,0.0024 -1.584399,0.349332 -0.145224,0.0084 -0.355282,0.05123 -0.49816,0.09405 -0.271568,0.04151 -0.536329,0.135512 -0.768945,0.275434 -0.215067,0.127455 -0.401452,0.296521 -0.536919,0.505913 -0.0031,0.0047 -0.0063,0.0092 -0.0093,0.01394 -0.04315,0.0684 -0.08099,0.140597 -0.112655,0.217041 -0.0037,0.0088 -0.0068,0.01794 -0.01035,0.02687 -0.03036,0.07766 -0.05627,0.157932 -0.07338,0.243395 -0.03628,0.08337 -0.07223,0.166714 -0.108519,0.250116 -0.0048,0.01087 -0.0097,0.02167 -0.01447,0.03255 0.04942,-0.03995 0.100706,-0.07839 0.152964,-0.115236 0.204592,-0.122997 0.414009,-0.242824 0.637685,-0.322461 0.13819,-0.04413 0.28048,-0.07184 0.425816,-0.08113 0.121766,0.01011 0.262233,0.03121 0.390673,0.02532 0.103621,0.01273 0.172484,-0.01514 0.220141,-0.06718 0.0062,-0.0047 0.01492,-0.0071 0.02066,-0.01241 0.260107,0.493035 1.009105,0.624137 1.538406,0.593246 -0.745537,0.351108 -1.662125,-7.93e-4 -2.398302,0.348298 0.0016,-0.0019 0.0026,-0.0043 0.0041,-0.0062 -0.0046,0.0026 -0.0093,0.0056 -0.01394,0.0083 -0.0021,0.0013 -0.0041,0.0028 -0.0062,0.0041 -0.006,0.0035 -0.01209,0.0074 -0.0181,0.01085 -0.05577,0.02834 -0.110376,0.06077 -0.163814,0.09818 -0.2569,0.156578 -0.511561,0.332917 -0.741555,0.533818 -0.116475,0.09545 -0.22919,0.194932 -0.333831,0.303339 -0.06028,0.07043 -0.122295,0.161801 -0.176217,0.261483 -0.155999,0.235757 -0.266457,0.498787 -0.307475,0.7953 -0.03032,0.09899 -0.06063,0.198141 -0.09095,0.29714 0.140539,-0.119086 0.283279,-0.251759 0.431499,-0.376721 0.118716,-0.05949 0.21962,-0.155543 0.326077,-0.240295 0.139436,-0.08021 0.290431,-0.132614 0.454753,-0.147796 0.01707,0.0026 0.03217,0.0011 0.05013,0.0057 0.08066,-5.29e-4 0.234593,0.03144 0.374653,0.04341 0.144364,0.02683 0.279799,0.03591 0.306959,-0.06459 0.536318,0.333859 1.183092,0.09966 1.754415,-0.02532 0.277063,-0.05314 0.711131,0.03251 0.278534,0.265615 -0.174214,0.429572 -0.657868,0.432433 -1.01234,0.635103 -0.157652,0.123373 -0.247894,0.274093 -0.286287,0.4346 -0.44385,0.290274 -0.968418,0.423148 -1.500167,0.418578 -0.0965,-7.93e-4 -0.193021,-0.006 -0.289388,-0.0155 0.610148,0.35125 1.23874,0.741307 1.952334,0.826307 0.156877,0.0037 0.312801,-0.01352 0.468188,-0.03462 0.09163,0.04725 0.188728,0.07922 0.288872,0.0956 0.377754,0.41682 0.833097,0.854964 1.439188,0.76326 0.24451,0.04661 0.516821,-0.03152 0.568442,-0.21394 0.432593,0.07296 0.912836,-0.147473 1.234032,-0.433048 0.577929,-0.314611 0.32975,-1.160791 0.873331,-1.476913 1.339639,-0.12039 2.392916,0.966063 3.700034,1.066083 -0.205843,-0.36272 -0.567542,-0.591492 -0.795816,-0.933791 0.45502,0.0315 0.899962,0.241681 1.352373,0.34158 0.95809,0.31709 2.235009,0.657029 3.02152,-0.20102 -0.588423,-0.163782 -1.107316,-0.534895 -1.467612,-1.026295 0.905433,0.141121 1.999369,0.423077 3.006535,0.399976 0.534394,-0.06898 1.201406,0.05834 1.635558,-0.312642 0.21507,-0.551191 -0.688432,-0.540068 -0.839739,-0.964801 -0.105879,-0.143586 -0.03316,-0.59354 0.07751,-0.565338 0.484563,0.516451 1.187916,-0.04096 1.663983,-0.276471 1.067282,0.04194 2.152359,0.309801 3.239079,0.268203 0.842963,0.0608 1.60306,-0.286419 2.39055,-0.51418 -0.06163,0.172066 -0.02212,0.413744 0.06098,0.568957 -0.912098,1.300488 -2.484181,1.955453 -3.986321,2.251025 -0.273262,0.119388 -0.835805,-0.01339 -0.930174,0.327628 0.297288,0.25451 0.798642,0.258794 1.071768,0.593762 -0.568203,0.303432 -0.969652,1.017913 -0.772046,1.671731 0.410136,0.76002 0.679649,1.71414 0.270785,2.53628 -0.06478,0.13742 -0.367159,0.61651 -0.29714,0.27182 -0.595199,0.17588 -1.102598,-0.3122 -1.366324,-0.79065 -0.422865,0.19857 -0.912799,0.0331 -1.256771,-0.24443 -0.2843,-0.36603 -0.801111,-0.64094 -1.230416,-0.32194 -0.0227,0.0117 -0.04218,0.0264 -0.06304,0.0398 -0.140602,0.0178 -0.279534,0.0392 -0.363802,0.0558 -0.121523,0.0212 -0.23655,0.0582 -0.3483,0.1018 -0.258921,0.0881 -0.496691,0.23514 -0.680577,0.43977 -0.09223,0.097 -0.222874,0.2581 -0.301276,0.42064 -0.0036,0.006 -0.0063,0.0132 -0.0098,0.0196 -0.0048,0.0106 -0.01069,0.0209 -0.01497,0.0315 -0.07996,0.15289 -0.143727,0.31581 -0.182933,0.48731 -0.03101,0.0946 -0.06201,0.1891 -0.09302,0.2837 0.138795,-0.12537 0.287629,-0.25225 0.451133,-0.34675 0.05326,-0.006 0.105574,-0.0218 0.15348,-0.045 0.02074,-0.0211 0.04244,-0.038 0.0646,-0.0532 0.106341,-0.0361 0.217757,-0.0573 0.337447,-0.0512 0.04136,-0.003 0.08566,-0.004 0.13126,-0.003 0.17023,0.0307 0.341622,0.0777 0.488857,0.0486 0.119581,0.0156 0.230619,0.0285 0.324012,0.0305 0.08971,0.0698 0.19573,0.12293 0.319878,0.14831 0.153133,0.12387 0.633778,-0.10018 0.485757,0.19069 -0.691457,0.0242 -1.497034,-0.19423 -2.082044,0.29404 -0.04418,0.0357 -0.08228,0.0736 -0.117305,0.11317 0.0073,-0.0452 0.01312,-0.0917 0.0217,-0.13539 -0.531503,0.71589 -1.181974,1.48167 -1.127065,2.43396 -0.0064,0.0792 -0.01273,0.15851 -0.01913,0.23771 0.07851,-0.0816 0.159319,-0.1642 0.243914,-0.24339 0.253788,-0.23759 0.540168,-0.44445 0.888833,-0.50385 0.142793,-0.0665 0.533861,0.0381 0.626835,0.0207 0.06251,0.0229 0.126432,0.0417 0.192239,0.0522 0.578231,0.18653 0.926766,-0.5419 1.496549,-0.35812 0.355134,0.0536 0.765331,0.21662 0.146759,0.27182 -0.463727,-0.006 -0.861081,0.32311 -1.041278,0.73019 -0.180533,0.20048 -0.333611,0.42131 -0.457854,0.65784 -0.149449,0.25077 -0.277069,0.52124 -0.299722,0.7891 -0.05278,0.21383 -0.08719,0.43281 -0.101288,0.6537 -0.01241,0.0785 -0.02479,0.15705 -0.03721,0.23565 0.100624,-0.10472 0.210847,-0.19766 0.327113,-0.28112 l 0.01291,0.0129 c 0.04353,-0.041 0.0897,-0.0769 0.136427,-0.11059 0.179925,-0.10987 0.372214,-0.19727 0.574125,-0.25786 0.196085,-0.0509 0.40169,-0.0772 0.607198,-0.1018 0.03313,-0.002 0.06597,-0.005 0.09922,-0.006 0.07079,0.007 0.119653,-0.007 0.156581,-0.0284 0.142409,-0.0176 0.283485,-0.0367 0.419097,-0.0656 -0.03306,-0.0165 -0.0697,-0.0284 -0.10387,-0.0434 0.710327,-0.0825 1.403861,-0.59466 1.682067,-1.25161 0.571193,0.0988 1.125173,-0.22713 1.495515,-0.63872 0.0565,0.41648 -0.13794,0.8904 -0.528132,1.07901 -0.445188,0.15351 -0.58933,0.5704 -0.525034,0.97513 -0.07029,-0.14706 -0.08902,-0.30587 0.02791,-0.49764 -0.340111,0.55134 -0.974752,0.63054 -1.568895,0.56224 0.267243,0.41289 0.690695,0.76523 1.198891,0.79633 0.215659,0.0156 0.58339,-2.6e-4 0.653193,-0.21807 0.153453,0.16046 0.353975,0.26997 0.588076,0.28215 0.48056,0.0493 1.037579,-0.1506 1.212329,-0.63872 0.0031,-0.44 0.35339,-0.7099 0.702799,-0.92449 0.640691,-0.32877 0.408215,-1.1535 0.802018,-1.63711 -0.0424,-0.28346 0.166889,-0.53883 0.427882,-0.65732 0.708446,-0.24762 0.733377,-1.09386 0.547769,-1.69913 -0.308255,-1.02604 0.716323,-1.73536 1.33377,-2.37194 0.314529,-0.2315 0.622708,-0.71244 0.461987,-1.08573 0.410982,0.28311 0.153953,0.94668 0.08475,1.37201 -0.298923,1.10283 0.770903,1.9856 1.719792,2.26395 1.837954,0.59181 3.655695,-0.39017 5.314923,-1.03405 0.170678,0.68318 0.225108,1.40737 0.0093,2.07688 -0.07914,0.64107 -0.862597,0.921 -0.866097,1.56786 0.136413,0.3768 -0.529503,0.29043 -0.776695,0.34313 -1.027544,-0.0468 -2.153479,0.11241 -2.899566,0.89504 -0.552292,-0.0298 -1.102461,0.14788 -1.563212,0.447 -0.454755,0.20013 -0.753956,0.66357 -0.789098,1.13946 -0.111252,0.16451 -0.211786,0.33545 -0.289388,0.51935 -0.400024,0.77788 -0.298712,1.73117 0.229444,2.42104 0.05535,0.0774 0.111045,0.15463 0.166396,0.23203 -0.0109,-0.051 -0.0195,-0.10168 -0.02532,-0.15193 -0.08396,-0.72345 0.343582,-1.36637 0.868164,-1.83865 0.288557,-10e-4 0.588195,-0.12553 0.804084,-0.32711 0.365493,-0.33941 0.236805,-0.13263 0.222726,0.16795 -0.61151,0.13801 -1.217022,0.86273 -0.952915,1.50843 -0.459205,0.51173 -0.597683,1.38869 0.02376,1.83193 l 0.06046,0.0631 0.0615,0.063 c 0.0067,-0.63364 0.513519,-1.04424 1.042828,-1.29501 0.712854,-0.063 1.4408,-0.63576 1.467094,-1.37304 -0.09293,-0.38752 0.333401,-0.67756 0.614434,-0.36845 -0.58505,0.54439 -0.602081,1.70764 -0.01757,2.25464 -0.03312,0.003 -0.06607,0.006 -0.09922,0.016 -0.292077,0.35221 -0.768332,0.40768 -1.130679,0.65991 0.102116,0.44873 0.656659,0.3623 0.996837,0.4439 v -5.3e-4 c 0.755134,0.0422 1.384061,-0.45006 1.81126,-1.02629 0.0164,-0.044 0.02246,-0.0789 0.02119,-0.10698 0.03881,-0.0316 0.07617,-0.0651 0.111104,-0.10128 0.649584,-0.58615 -0.05629,-1.43451 0.16433,-2.11718 0.343014,-0.29728 0.894829,-0.31548 1.111044,-0.78083 0.315862,0.67958 -0.64747,0.91845 -0.804085,1.48156 -0.05724,0.45079 0.202076,0.81095 0.568439,1.02836 -0.08322,-0.0223 -0.161959,-0.0589 -0.229441,-0.12454 -0.337916,0.30817 -0.445257,0.78851 -0.811321,1.07487 -0.405956,0.29276 0.581715,0.0922 0.721402,0.0982 0.406101,-0.0875 1.069829,-0.32745 1.045932,-0.82527 0.135054,0.008 0.268701,-7.9e-4 0.393774,-0.031 0.950931,-0.57309 1.076278,-1.83733 0.996839,-2.84531 0.292817,-0.52065 0.803426,-0.99155 1.086239,-1.56114 0.453769,-0.54186 0.385686,-1.29622 0.03669,-1.87017 -0.43171,-0.59809 -0.454882,-1.72652 0.356568,-2.00092 0.339998,-0.19218 0.820092,0.19216 1.068668,-0.16433 -0.01532,-0.35077 -0.451231,-0.65033 -0.46147,-1.0604 -0.228058,-1.03825 0.721421,-1.75609 0.988052,-2.67167 0.06593,-0.406898 -0.431713,-0.31785 -0.655772,-0.20205 -0.335841,0.13502 -1.174028,0.0332 -0.898139,-0.474911 0.435882,-0.448101 1.324292,-0.710512 1.223698,-1.49293 -0.350237,0.08307 -0.711576,0.149836 -1.072801,0.115236 0.77593,-0.47122 1.042323,-1.584065 0.555003,-2.354379 -0.211031,0.708412 -1.319651,0.705366 -1.569929,0.03256 -0.149802,-1.112199 0.966139,-1.82105 1.315683,-2.783808 0.380984,0.7156 0.892694,1.366298 1.524455,1.876888 0.668264,0.432581 1.357289,1.009992 2.195214,1.016992 0.463608,0.465752 1.121187,0.771668 1.786972,0.714169 0.775774,-0.187788 1.523293,-0.510471 2.316136,-0.657841 0.858403,-0.176721 1.89684,-0.564298 2.077392,-1.543058 0.260289,-0.04048 0.687178,-0.08336 0.911574,-0.350367 1.093938,-1.383421 2.265391,-2.995028 2.17661,-4.850868 -0.0918,-0.285089 -0.08546,-0.561766 0.196372,-0.744657 0.687731,-1.156959 0.312864,-2.598801 -0.149347,-3.770828 -0.06478,-0.505243 -0.616604,-0.567388 -0.936376,-0.832509 -0.07974,-0.999167 -0.556398,-1.963539 -1.297594,-2.647899 -0.554548,-0.44223 -1.136547,-1.100352 -1.918747,-0.993222 -0.635932,0.194108 -1.043253,-0.392759 -1.577166,-0.6134 -0.840862,-0.274119 -1.761119,-0.09722 -2.631363,-0.124023 -1.736164,-0.06765 -3.686911,0.718772 -4.371308,2.421043 -0.154811,0.57612 -0.586857,1.408332 0.01447,1.866551 0.282615,0.04836 0.375767,0.28126 0.390155,0.544671 0.546428,1.300588 2.271477,2.246133 3.586345,1.465543 0.324824,-0.03342 0.563539,-0.63672 0.109037,-0.63872 -0.695338,0.349118 -1.75801,-0.166701 -1.652611,-1.009759 1.72439,-0.137231 3.531193,-0.754795 4.759399,-2.048454 0.181113,0.634111 0.508368,1.321006 1.057299,1.752349 0.459187,0.463708 1.22019,0.439065 1.643311,0.917773 -0.355727,0.595 -0.580678,1.366737 -0.375687,2.073259 0.06858,0.733388 0.675582,1.190697 1.238684,1.570445 -1.544182,0.711473 -2.387759,2.434974 -2.4629,4.075205 -0.736243,-0.08908 -1.488755,0.0072 -2.192629,0.234093 -0.790456,0.08371 -0.922046,1.10113 -1.633492,1.29863 -0.09662,-0.193802 0.06265,-0.603985 -0.03049,-0.874365 -0.581025,-1.007693 -1.497359,-1.872835 -2.552298,-2.393135 -0.805653,-0.30353 -1.736476,-0.59789 -2.591056,-0.32453 -0.798061,-1.071259 -1.72905,-2.057953 -2.83032,-2.821533 -0.860991,-0.68313 -1.887918,-1.018077 -2.953308,-1.161169 -0.381728,-0.533225 -0.623567,-1.286666 -0.207222,-1.859836 1.145572,-0.944578 2.757932,-0.684889 4.09329,-1.18804 0.05374,0.0016 0.107566,0.0063 0.161231,0.0072 0.243806,0.116829 0.551879,-0.149511 0.471289,-0.353468 0.0747,0.0071 0.149866,0.01548 0.224277,0.0217 0.102661,0.01101 0.205327,0.02207 0.307991,0.03307 -0.711184,-0.444341 -1.204613,-1.239023 -1.240234,-2.066541 -0.114266,-1.796661 1.490689,-3.146838 3.049942,-3.67678 0.204097,-0.07222 0.659093,-0.147402 0.674894,-0.383955 0.313481,0.04391 0.674028,-0.01331 0.599963,-0.410311 -0.139229,-0.0435 -0.279561,-0.08304 -0.420129,-0.121957 -0.396621,-0.654524 -0.353692,-1.490845 -0.131776,-2.203482 0.589214,-2.124411 2.756303,-3.342703 4.800225,-3.758943 0.221451,0.02635 0.65175,-0.166 0.574643,-0.388091 0.455721,-0.0077 0.911214,-0.02548 1.365808,-0.07028 0.333084,-0.04538 -0.553484,-0.335214 -0.785482,-0.425816 -5.22094,-1.0204 -10.825493,0.501955 -14.957226,3.817856 -0.929423,0.81226 -1.871292,1.626814 -2.696993,2.546614 -0.291232,0.21123 -0.273077,0.92891 -0.747242,0.761712 -0.209592,-0.649121 0.46364,-1.146855 0.653706,-1.727544 0.349436,-0.594072 -0.08793,-1.393589 -0.773078,-1.436089 -0.439875,-0.03939 -0.980964,0.253619 -1.103294,0.677478 0.239959,0.208161 0.702329,-0.112911 0.890903,0.27957 0.374798,0.69747 -0.591132,1.014801 -0.781347,1.599903 -0.367998,1.901399 -0.1461,3.863126 -0.318844,5.786726 0.04388,0.86913 -0.418213,1.723041 -1.213879,2.1208 -0.565057,0.396912 -1.332095,0.448363 -1.822627,0.946713 -0.03673,-0.298003 -0.238342,-0.56166 -0.503846,-0.697632 0.388903,-0.111226 0.737658,-0.320085 0.946195,-0.696598 -0.331703,0.06735 -0.716473,0.0016 -0.913638,-0.301791 -0.153125,-0.151498 -0.321096,-0.855385 -0.0041,-0.548286 0.451898,0.462457 1.352193,0.237802 1.468128,-0.404627 0.02204,-0.451509 -0.609663,-0.05438 -0.700733,-0.514181 -0.44029,-0.912169 0.84895,-1.448014 0.687814,-2.335773 0.552148,0.26597 1.206605,-0.04557 1.519287,-0.532784 -0.339738,0.08591 -0.762076,0.037 -0.96325,-0.285771 0.461418,0.128252 1.084943,0.01638 1.291395,-0.467672 0.198625,-0.266861 0.0127,-0.62506 -0.325562,-0.584462 -0.599721,0.0199 -0.466238,-0.795544 -0.331245,-1.171503 0.586073,-1.90884 -0.723964,-3.865867 -2.352829,-4.777486 0.359683,-0.1611 0.813168,-0.07913 1.208196,-0.06563 -0.58851,-1.207979 -2.060051,-1.614271 -3.309876,-1.52187 0.01974,-0.504579 0.466304,-0.857404 0.896588,-1.037664 -0.513437,-0.67183 -1.295554,-1.107102 -2.118736,-1.267622 -0.133765,-0.05352 -0.264964,-0.08119 -0.394806,-0.08992 z m -8.009332,7.427455 c 0.112041,0.07673 0.209204,0.148603 0.09457,0.213424 -0.0357,0.05215 -0.07481,0.09883 -0.115237,0.142626 0.03636,-0.10464 0.04819,-0.216625 0.02739,-0.327628 -0.0016,-0.01053 -0.0046,-0.01868 -0.0067,-0.02842 z m -0.155546,11.28355 c 0.0051,0.01442 0.0081,0.02903 0.01344,0.04341 -0.0048,0.0049 -0.01048,0.01408 -0.0155,0.01963 0.0016,-0.02088 7.93e-4,-0.04211 0.0021,-0.06304 z M 51.93998,92.6946 c 0.01098,0.0057 0.02297,0.01852 0.03617,0.04082 -0.129574,0.221945 -0.113009,-0.08111 -0.03617,-0.04082 z m 12.310362,2.215367 c 0.440137,0.136432 0.821991,0.391874 1.005623,0.83561 0.08916,0.653536 -0.09168,1.282337 -0.396359,1.861383 0.262866,-0.617032 0.393615,-1.278168 0.301273,-1.966804 -0.225293,-0.339606 -0.546338,-0.577252 -0.910537,-0.730189 z M 42.609801,98.163 c 0.07338,0.0044 0.150474,0.02162 0.230995,0.05426 -0.03681,0.156159 -0.107117,0.321691 -0.166915,0.48886 -0.453202,0.257238 -0.966753,0.467005 -1.473812,0.343648 0.06625,-0.005 0.132541,-0.01593 0.198954,-0.03824 0.347038,-0.283236 0.697135,-0.879001 1.210778,-0.848528 z"
         id="path26442" />
      <g
         transform="translate(6.5481034,9.3544335)"
         id="g26500">
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26504);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 61.983254,103.77298 c -1.14251,-0.17199 -1.30516,-1.85022 -0.566375,-2.53766 -0.281032,-0.30911 -0.707337,-0.0192 -0.61441,0.36832 -0.04194,1.17593 -1.869726,1.93472 -2.5723,0.87123 -0.452255,-0.68053 0.206539,-1.51986 0.869542,-1.66949 0.01408,-0.30058 0.142753,-0.50763 -0.222739,-0.16822 -0.415139,0.38762 -1.142008,0.49911 -1.498431,-0.0268 -0.527738,-0.640348 -0.198109,-1.644957 0.53399,-1.967148 0.460751,-0.29912 1.011092,-0.47701 1.563383,-0.44717 0.746086,-0.78263 1.871687,-0.941689 2.89923,-0.894869 0.247193,-0.0527 0.913099,0.0335 0.776687,-0.343299 0.0035,-0.646861 0.787168,-0.926783 0.86631,-1.567852 0.215807,-0.66951 0.16148,-1.393878 -0.0092,-2.077059 -1.659226,0.64388 -3.476911,1.626201 -5.314865,1.034389 -0.948889,-0.27835 -2.018943,-1.16146 -1.720017,-2.264288 0.07622,-0.46845 0.383395,-1.22741 -0.228756,-1.44694 -0.347007,-0.381032 0.361889,-0.670553 0.528476,-0.952223 0.803646,-0.883237 1.603989,-2.045718 1.433852,-3.292829 -0.362342,-0.875581 -1.494764,-1.020779 -2.328886,-0.95704 -1.102162,0.110781 -2.084542,0.767511 -3.217668,0.685781 -1.086718,0.0416 -2.171848,-0.226301 -3.239131,-0.26824 -0.476067,0.235508 -1.179421,0.79275 -1.663983,0.276299 -0.110673,-0.0282 -0.183737,0.42209 -0.07786,0.565679 0.151307,0.424731 1.054982,0.413441 0.839915,0.964632 -0.434153,0.37098 -1.101337,0.24384 -1.635732,0.312819 -1.007166,0.0231 -2.100756,-0.25921 -3.006189,-0.40033 0.360296,0.4914 0.879186,0.862869 1.467609,1.026652 -0.786511,0.858049 -2.063323,0.518027 -3.021415,0.200938 -0.452409,-0.0999 -0.897456,-0.309999 -1.352476,-0.341498 0.228276,0.342299 0.589975,0.570889 0.795817,0.933609 -1.307119,-0.100021 -2.360376,-1.186292 -3.700013,-1.065901 -0.543583,0.316122 -0.295747,1.16196 -0.873676,1.476571 -0.403389,0.358651 -1.058529,0.62302 -1.553738,0.319699 -0.278959,-0.402879 0.05826,-0.859359 0.152273,-1.25815 -0.644152,-0.261228 -1.044812,0.470742 -1.441428,0.794441 -0.896132,0.30109 -1.845292,-1.06072 -1.032151,-1.697051 0.354474,-0.202671 0.837955,-0.205708 1.012171,-0.63528 0.432596,-0.233109 -0.0013,-0.31841 -0.278365,-0.265269 -0.607657,0.132929 -1.300867,0.38935 -1.855528,-0.0455 -0.455109,-0.237011 -0.770848,-0.993619 -0.232889,-1.313961 0.768407,-0.57967 1.808095,-0.0999 2.636187,-0.489889 -0.639088,0.0373 -1.600944,-0.159621 -1.632286,-0.9474 0.06769,-0.92386 1.187507,-1.2332 1.963015,-1.081071 0.837806,0.0592 1.349527,0.868751 2.186258,0.928801 0.436895,0.11074 0.907734,0.27961 1.163753,0.67661 1.26415,0.0696 2.389917,-0.69701 3.64086,-0.78546 0.372805,-0.08 0.903347,-0.02 1.180207,-0.11233 0.01051,-0.2687 0.088,-0.72898 -0.312127,-0.68833 -0.476377,-0.14779 -0.788074,-0.675781 -0.871608,-1.09898 -0.100654,0.48014 -0.01132,0.97207 0.05099,1.451069 -1.96901,-1.059959 -2.856935,-3.641569 -2.053268,-5.709219 0.0076,-0.22453 0.161685,-0.48371 0.265959,-0.590481 -0.492269,-1.323319 0.271939,-2.78579 1.14033,-3.704169 -0.30848,-0.41158 0.09166,-1.000791 0.381716,-1.32223 0.357752,-0.387561 0.941013,-0.0824 1.319611,-0.446751 0.334765,-0.168659 0.83868,-0.78307 1.138809,-0.254669 0.183162,0.247559 0.01058,0.63647 -0.0248,0.817179 0.546293,0.0315 1.082991,-0.10426 1.621264,-0.173629 -0.39186,0.424009 -0.788455,0.895459 -1.345654,1.101739 1.338481,0.675731 3.272324,0.701911 4.251248,-0.59669 0.465145,-0.105639 0.299209,0.48942 0.340374,0.74207 0.213759,1.1382 1.488923,1.666611 2.540413,1.61368 0.354266,0.0895 0.644094,0.405821 0.689021,0.770321 0.490534,-0.498351 1.257395,-0.5498 1.822453,-0.946711 0.795666,-0.39776 1.257932,-1.251669 1.214053,-2.1208 0.172745,-1.923599 -0.04898,-3.88567 0.319017,-5.78707 0.190214,-0.5851 1.156144,-0.90243 0.781346,-1.5999 -0.188574,-0.39248 -0.650945,-0.0709 -0.890901,-0.27906 0.122329,-0.42386 0.663243,-0.71738 1.103118,-0.67799 0.685149,0.0425 1.122516,0.84253 0.773081,1.4366 -0.190066,0.58069 -0.863473,1.07826 -0.653881,1.72738 0.474165,0.1672 0.456354,-0.55083 0.747586,-0.76206 0.825701,-0.9198 1.767395,-1.73435 2.696818,-2.54661 4.131734,-3.3159 9.736286,-4.83826 14.957227,-3.81786 0.231997,0.0906 1.118626,0.3808 0.785542,0.42618 -1.746183,0.17211 -3.506001,-0.0475 -5.23867,0.24975 -4.363993,0.52589 -8.825024,2.34303 -11.566509,5.92486 -0.255852,0.32699 -0.501621,0.67778 -0.726282,1.03699 2.946467,-0.95797 6.078676,-1.63228 9.182352,-1.14705 0.732398,0.0955 1.455348,0.25774 2.160283,0.47801 0.09702,0.52005 -0.553021,0.45841 -0.864031,0.34796 -3.593661,-0.43418 -7.350252,-0.0448 -10.661883,1.49862 0.419193,1.73297 2.156587,2.76783 3.651112,3.53535 1.296919,0.59978 2.692408,0.87465 4.105865,0.960501 0.40218,0.176599 -0.01087,0.64168 -0.319016,0.49402 -3.346455,-0.0561 -6.843096,-1.60015 -8.58793,-4.559241 -0.614331,0.57288 -0.163259,1.49085 -0.04243,2.17933 0.273185,1.15478 0.823179,2.36073 0.54334,3.558131 -0.454866,0.84415 -1.641511,0.58528 -2.239998,1.24161 1.136185,0.89467 2.680124,0.52784 4.020422,0.550529 1.800193,-0.0898 3.746431,0.068 5.212476,1.231191 1.10127,0.76358 2.032384,1.75036 2.830444,2.82162 0.85458,-0.27336 1.785059,0.021 2.590713,0.32453 1.054939,0.5203 1.971635,1.385389 2.55266,2.39308 0.09314,0.27038 -0.06614,0.68045 0.03048,0.87425 0.711446,-0.1975 0.842637,-1.21453 1.633093,-1.29824 0.703874,-0.2269 1.456785,-0.32322 2.193028,-0.23414 0.07514,-1.64023 0.918374,-3.36408 2.462557,-4.075551 -0.563102,-0.379749 -1.169774,-0.836609 -1.238361,-1.569999 -0.204992,-0.706521 0.01998,-1.478531 0.375708,-2.073531 -0.423122,-0.478709 -1.18437,-0.453849 -1.643557,-0.917559 -0.548931,-0.431341 -0.876287,-1.11828 -1.0574,-1.75239 -1.228206,1.293659 -3.034665,1.911219 -4.759055,2.04845 -0.105399,0.843059 0.956929,1.358539 1.652267,1.00942 0.454502,0.002 0.215961,0.6053 -0.108862,0.638719 -1.314868,0.780591 -3.039915,-0.16495 -3.586343,-1.465539 -0.01439,-0.263411 -0.107368,-0.495971 -0.389985,-0.544331 -0.601324,-0.45822 -0.16928,-1.290429 -0.01447,-1.86655 0.684398,-1.702269 2.634975,-2.48886 4.371139,-2.42121 0.870244,0.0268 1.790499,-0.1501 2.631361,0.12402 0.533913,0.22064 0.941234,0.80734 1.577165,0.613231 0.782201,-0.107131 1.364155,0.551489 1.918703,0.993719 0.741198,0.68436 1.217898,1.648571 1.297638,2.64774 0.319773,0.265121 0.871567,0.32704 0.936345,0.832281 0.462211,1.172029 0.837284,2.61409 0.149553,3.77105 -0.281837,0.18289 -0.288171,0.45974 -0.196374,0.74483 0.08878,1.85584 -1.082757,3.4671 -2.176695,4.85052 -0.224396,0.267011 -0.651198,0.30972 -0.911487,0.350198 -0.180552,0.97876 -1.219012,1.36643 -2.077416,1.543151 -0.792842,0.14737 -1.540687,0.470471 -2.316461,0.658259 -0.665782,0.0575 -1.323015,-0.248758 -1.786623,-0.714509 -0.837925,-0.007 -1.527355,-0.584068 -2.195621,-1.016649 -0.631759,-0.51059 -1.14341,-1.16163 -1.524394,-1.87723 -0.349544,0.96276 -1.465141,1.67144 -1.315339,2.78364 0.250277,0.672809 1.358553,0.67601 1.569585,-0.0324 0.48732,0.770311 0.221268,1.883161 -0.554662,2.354382 0.361225,0.0346 0.722569,-0.032 1.072806,-0.11507 0.100592,0.782418 -0.787818,1.045009 -1.223698,1.49311 -0.275889,0.508108 0.561951,0.609748 0.897792,0.474728 0.22406,-0.1158 0.721876,-0.20502 0.655947,0.20188 -0.266631,0.91558 -1.216115,1.63377 -0.988057,2.672022 0.01024,0.410069 0.446315,0.709628 0.461645,1.060399 -0.248576,0.356489 -0.728668,-0.0282 -1.068668,0.163979 -0.811448,0.274391 -0.788575,1.403061 -0.356865,2.001152 0.348996,0.573958 0.41697,1.327949 -0.0368,1.869808 -0.282813,0.569592 -0.793279,1.040471 -1.086096,1.561127 0.07944,1.00798 -0.04564,2.2727 -0.996572,2.84579 -0.748855,0.1807 -1.798542,-0.35662 -1.68879,-1.22094 0.156615,-0.56311 1.119952,-0.8018 0.80409,-1.48139 -0.216215,0.46535 -0.768374,0.48338 -1.111388,0.78066 -0.220617,0.68267 0.485593,1.5312 -0.163991,2.11735 -0.287568,0.29774 -0.716529,0.4449 -1.126543,0.39825 z M 45.428194,83.380773 c -0.105569,-0.178401 -0.148085,0.25365 0,0 z"
           id="path26444" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26506);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 58.455477,68.285052 c 2.032934,-3.68823 5.923569,-5.97966 9.925635,-6.94456 2.132515,-0.47022 4.364503,-0.9088 6.541921,-0.54576 0.35084,0.26941 -0.210079,0.54711 -0.473353,0.51578 -2.043922,0.41624 -4.211098,1.63428 -4.800312,3.75869 -0.254418,0.817 -0.274076,1.79687 0.334775,2.4786 -3.842144,-1.2036 -7.952735,-0.37111 -11.657513,0.94534 0.04295,-0.0694 0.0859,-0.13873 0.128847,-0.20809 z"
           id="path26446" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26508);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 66.808458,73.899182 c -2.844943,-0.23852 -5.91684,-1.074839 -7.777097,-3.394509 -0.284141,-0.384351 -0.481988,-0.832371 -0.564168,-1.303911 3.401801,-1.67364 7.330091,-2.17113 11.064954,-1.58888 0.278263,0.394661 -0.354293,0.48817 -0.605858,0.57719 -1.559254,0.529941 -3.16434,1.88016 -3.050075,3.67682 0.03562,0.82752 0.52905,1.622021 1.240235,2.06636 -0.102664,-0.011 -0.20533,-0.0221 -0.307991,-0.0331 z"
           id="path26448" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26510);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 63.108424,103.93697 c 0.366064,-0.28636 0.47375,-0.7667 0.811665,-1.07487 0.272846,0.26551 0.72318,0.0602 0.955667,0.3259 0.04516,0.51298 -0.63382,0.75802 -1.04593,0.84681 -0.139689,-0.006 -1.127358,0.19496 -0.721402,-0.0978 z"
           id="path26450" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26512);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 57.140829,77.411112 c -0.507749,-0.0616 -1.15709,-0.292559 -1.371149,-0.739309 0.327226,-0.975911 1.731935,-0.50976 2.168346,-1.35324 0.11878,-1.64976 -0.739944,-3.16454 -0.900551,-4.78868 -0.02331,-0.377601 0.280498,-1.086841 0.721402,-0.82545 0.398714,0.366949 0.506592,0.94971 0.920673,1.31718 1.58882,1.95141 4.202994,2.566069 6.584096,2.87383 0.24393,0.0717 0.897302,0.163219 0.85295,0.26446 -1.365258,0.59317 -3.065137,0.268269 -4.257974,1.25182 -0.446151,0.6142 -0.138673,1.439 0.289309,1.973899 -1.64623,-0.336389 -3.338531,0.0996 -5.007102,0.0255 z"
           id="path26452" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26514);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 61.166081,104.60945 c -0.340178,-0.0816 -0.894893,0.005 -0.997011,-0.44373 0.362349,-0.25223 0.838602,-0.30787 1.130678,-0.66008 0.382461,-0.11585 0.762683,0.264 1.143228,0.005 0.156961,-0.0727 0.667657,-0.28465 0.534532,0.0724 -0.427199,0.57623 -1.056293,1.06812 -1.811427,1.02595 z"
           id="path26454" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26516);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 51.400612,99.725693 c -0.91634,-0.0477 -1.322856,-1.57317 -0.374138,-1.900319 0.390193,-0.188611 0.584979,-0.662522 0.528479,-1.079 -0.370343,0.411588 -0.92467,0.737508 -1.495863,0.63872 -0.435194,1.02765 -1.885625,1.70665 -2.829112,0.928788 -0.692961,-0.64461 -0.03775,-1.87307 0.855761,-1.86173 0.618572,-0.0552 0.208376,-0.218588 -0.146759,-0.272158 -0.569781,-0.183783 -0.918319,0.544819 -1.49655,0.358288 -0.847577,-0.134789 -1.465929,-1.36448 -0.709902,-1.97521 0.585008,-0.48827 1.39028,-0.269579 2.081738,-0.29373 0.148019,-0.29087 -0.332623,-0.067 -0.485757,-0.19086 -0.750732,-0.15349 -0.888277,-1.259588 -0.212908,-1.608859 0.429305,-0.319001 0.946566,-0.0437 1.230866,0.322331 0.343972,0.277519 0.833628,0.442619 1.256492,0.244049 0.263726,0.478449 0.771126,0.966869 1.366326,0.79099 -0.07002,0.344689 0.232191,-0.134741 0.296968,-0.272161 0.408863,-0.82214 0.139351,-1.776259 -0.270785,-2.53628 -0.197608,-0.65382 0.204188,-1.368128 0.77239,-1.67156 -0.273128,-0.334968 -0.774824,-0.339429 -1.072113,-0.59394 0.09437,-0.341019 0.657228,-0.20815 0.93049,-0.327538 1.502138,-0.295571 3.074253,-0.950272 3.98635,-2.25076 -0.144509,-0.26992 -0.168624,-0.80917 0.270093,-0.769641 0.96477,-0.19526 2.155615,0.0149 2.729898,0.88057 0.218326,1.62819 -0.799809,3.106349 -1.902383,4.197501 0.477319,0.376118 0.101449,1.031229 -0.282564,1.31386 -0.617446,0.636579 -1.642132,1.34566 -1.333875,2.371698 0.185608,0.605272 0.160652,1.451862 -0.547793,1.69948 -0.260992,0.118491 -0.470256,0.37351 -0.427859,0.656971 -0.393803,0.483611 -0.161329,1.308341 -0.802019,1.637109 -0.349409,0.214591 -0.699721,0.484661 -0.702797,0.924661 -0.174749,0.488119 -0.732113,0.688041 -1.212674,0.63873 z"
           id="path26456" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26518);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 58.170225,104.14574 c -0.68216,-0.48654 -0.449983,-1.49726 0.118512,-1.97197 0.218382,0.49831 0.756012,0.71431 1.271929,0.70556 -0.600782,0.23593 -1.26087,0.66882 -1.268487,1.3925 l -0.06131,-0.0634 z"
           id="path26458" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26520);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 57.063658,102.72292 c -0.528154,-0.68987 -0.62963,-1.64308 -0.229608,-2.42096 0.15472,-0.366658 0.401169,-0.682338 0.640262,-0.996578 -0.108161,0.578752 -0.140351,1.537378 0.663528,1.598528 -0.591352,0.50857 -1.082398,1.23564 -0.90813,2.05121 -0.05535,-0.0774 -0.110701,-0.1548 -0.166052,-0.2322 z"
           id="path26460" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26522);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 51.248339,75.209703 c -1.143903,-0.0871 -2.000592,-1.218061 -1.982307,-2.327511 -0.924137,1.237491 -2.739768,1.312321 -4.06315,0.74257 -0.41299,-0.13351 -0.823295,-0.274779 -1.23541,-0.412529 0.500803,-0.104271 1.311987,-0.298101 1.53169,-0.65939 -0.495945,0.0934 -0.995535,-0.0333 -1.491724,-0.0579 0.363121,-0.19637 0.488266,-0.629949 0.384471,-1.012169 -1.061381,1.18399 -3.389813,1.039609 -4.054189,-0.48714 -0.139072,-0.41505 -0.106126,-0.980451 0.319017,-1.21749 0.336995,0.153649 0.307654,0.893669 0.788236,0.65181 0.357777,-0.2716 0.418476,-1.0269 1.004591,-0.92535 0.364959,-0.005 0.712015,-0.476 0.302479,-0.711761 -0.475488,-0.52683 -0.351472,-1.57769 0.440284,-1.70257 0.656294,-0.16793 1.678838,-0.16667 1.835545,-0.95704 -0.81148,-0.10196 -1.292637,-1.08718 -1.030082,-1.82797 -0.650773,-0.18 -0.876124,-1.08601 -0.488513,-1.60335 -0.498309,-0.31871 -0.341482,-1.06286 0.106796,-1.34221 0.30533,-0.49058 -0.0544,-1.15111 -0.574643,-1.29811 -0.33529,-0.35396 0.282921,-0.63553 0.586356,-0.56293 0.341757,-1.5e-4 0.653834,0.16304 0.971518,0.26734 -0.227859,-0.42437 -0.694154,-0.64091 -1.166509,-0.52847 0.762723,-0.69665 1.85426,-0.48112 2.748308,-0.22171 1.049158,0.34918 1.977319,-0.85504 3.047446,-0.4269 0.823182,0.16052 1.604881,0.59551 2.118318,1.26734 -0.430284,0.18026 -0.876664,0.53309 -0.896412,1.03767 1.249824,-0.0924 2.721536,0.31406 3.310047,1.52204 -0.395027,-0.0135 -0.848858,-0.0956 -1.20854,0.0655 1.628864,0.91162 2.938918,2.86879 2.352845,4.77763 -0.134994,0.37596 -0.26815,1.19127 0.331572,1.17136 0.338272,-0.0406 0.523843,0.31743 0.325219,0.58429 -0.206453,0.48405 -0.829808,0.596091 -1.291223,0.46784 0.201171,0.32277 0.62351,0.371851 0.963249,0.28594 -0.312681,0.48721 -0.96714,0.798581 -1.519287,0.532611 0.161135,0.887759 -1.127933,1.42361 -0.687641,2.33578 0.09107,0.459799 0.722767,0.0625 0.700733,0.51401 -0.115934,0.642429 -1.016209,0.867189 -1.468106,0.40473 -0.316961,-0.3071 -0.149225,0.39668 0.0039,0.548179 0.197167,0.30338 0.581935,0.369141 0.913638,0.301791 -0.378915,0.684129 -1.215521,0.827049 -1.928562,0.804089 z"
           id="path26462" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26524);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 50.159688,99.661614 c -0.508197,-0.0311 -0.931651,-0.383622 -1.198894,-0.796512 0.594145,0.0683 1.228785,-0.0109 1.568898,-0.56224 -0.24269,0.398042 0.09165,0.65596 0.281806,0.95567 0.119722,0.399111 -0.385752,0.422352 -0.65181,0.403082 z"
           id="path26464" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26526);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 46.185424,99.282654 c 0.05386,-0.843902 0.391118,-1.662531 1.003212,-2.25516 -0.292089,0.579038 0.04808,1.322308 0.699358,1.410419 0.287383,-3.1e-5 0.355832,0.36771 0.01722,0.336241 -0.659486,0.006 -1.298243,0.26674 -1.756996,0.744138 0.01242,-0.0786 0.0248,-0.157099 0.03721,-0.235638 z"
           id="path26466" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26528);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 45.151207,94.066084 c 0.172339,-0.753851 0.766156,-1.366271 1.537892,-1.500682 0.231423,-0.0455 0.871072,-0.145069 0.843594,-0.0263 -0.475195,0.257781 -0.942033,0.95889 -0.361233,1.376971 -0.208506,0.0645 -0.750997,-0.0898 -1.106612,-0.0622 -0.403792,-0.02069 -0.725438,0.242081 -1.006658,0.496091 0.03101,-0.0946 0.06201,-0.189251 0.09302,-0.283871 z"
           id="path26468" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26530);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 44.50973,96.975122 c -0.05491,-0.952288 0.595736,-1.718418 1.127238,-2.434309 -0.129639,0.659619 -0.129798,1.517099 0.571267,1.864129 0.272105,0.199631 -0.390278,-0.0304 -0.58505,0.0603 -0.464887,0.0792 -0.818709,0.421237 -1.132745,0.747588 0.0064,-0.0792 0.01288,-0.15848 0.0193,-0.23771 z"
           id="path26470" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26532);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 41.286498,68.810092 c -1.197447,-0.0391 -2.34687,-0.87967 -2.640319,-2.06017 0.773077,-0.006 1.769971,0.12355 2.272386,-0.61047 0.200547,-0.1134 -0.245653,-0.24511 -0.28939,-0.39481 -0.82851,-0.79902 -2.195272,-0.80768 -2.89319,-1.75975 -0.232193,-0.36415 -0.238171,-0.93366 0.15434,-1.18443 -0.02457,-0.32172 -0.178598,-0.89804 0.31695,-0.92604 0.847819,-0.24466 1.788198,-0.18888 2.615515,-0.37483 0.470023,-0.67678 1.372295,-0.27585 2.031918,-0.52296 0.334755,0.0271 0.81067,-0.44832 1.004514,-0.16114 0.28848,0.52415 -0.377543,0.9307 -0.452533,1.34778 0.182598,0.43147 0.3178,0.99372 -0.0056,1.37927 0.189809,0.35285 0.913956,0.52713 0.682128,1.04937 -0.228095,0.71738 0.561227,1.2005 1.13895,1.37322 -0.09928,1.01251 -1.281624,1.29376 -2.128382,1.30362 -0.53678,0.014 -1.454711,0.1037 -1.45452,0.81855 0.11226,0.28514 0.06126,0.77314 -0.352778,0.72279 z m 0.308681,-6.31418 c 0.21372,-10e-4 0.493321,-0.23047 0.356912,-0.37964 -0.24554,-0.0559 -0.556658,0.0215 -0.456127,0.33417 0.0326,0.0121 0.0431,0.11746 0.09922,0.0455 z"
           id="path26472" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26534);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 41.622053,62.683332 c -0.656565,-0.0902 -0.0693,-1.19647 0.344509,-0.69247 0.115224,0.26236 0.05969,0.78129 -0.344509,0.69247 z"
           id="path26474" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26536);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 40.044199,66.820202 c -0.468451,-0.052 -0.41689,-0.86308 0.07304,-0.80133 0.15663,-0.23093 0.641921,-0.51432 0.713825,-0.0641 0.08251,0.44031 -0.348513,0.89249 -0.786861,0.86541 z"
           id="path26476" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26538);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 40.205429,79.996313 c -0.53805,-0.17169 -0.722516,-0.79885 -1.226454,-0.997011 -0.09167,0.384061 -0.581912,0.425101 -0.799262,0.123331 -1.034439,-0.706991 -0.858462,-2.297771 -1.830724,-3.00205 -0.349242,-0.056 -1.024929,-0.14635 -0.851627,-0.661461 0.308223,-0.75652 0.531282,-1.85162 -0.168121,-2.449459 -0.347708,0.009 -0.718296,0.005 -1.036285,-0.0834 -0.580074,0.22653 -1.164899,1.005561 -1.84726,0.60289 -0.611925,-0.44497 -0.418891,-1.65471 0.413412,-1.666739 0.347065,0.004 0.276557,-0.34452 -0.0021,-0.37827 -0.534203,-0.11552 -1.304245,0.269949 -1.649521,-0.339001 -0.503408,-0.77246 0.490439,-1.73837 1.289843,-1.488969 0.276515,-0.0246 0.646979,0.184669 0.853005,-0.0648 -0.446959,-0.52856 -0.646574,-1.53716 0.09508,-1.90996 0.747675,-0.34686 1.561615,0.36129 1.584055,1.12448 0.01751,0.38686 0.121454,0.844811 0.563618,0.89642 -0.300045,-0.674059 0.441006,-1.461989 1.13137,-1.15411 0.912944,0.262831 1.141579,1.501911 0.647677,2.2214 0.90604,0.574981 0.614482,1.91212 1.457276,2.54317 0.656545,0.63218 1.497005,1.03814 2.131825,1.695671 -0.605977,0.89931 -0.01605,2.05183 -0.47971,3.001289 -0.191802,0.68795 -0.291395,1.419871 -0.09976,2.101591 -0.05879,-0.0384 -0.117592,-0.0767 -0.176389,-0.11506 z"
           id="path26478" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26540);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 39.302125,66.908402 c -0.677699,-0.0755 -0.573916,-0.91432 -0.534679,-1.3994 0.02392,-0.24446 0.423319,0.0903 0.585666,0.1881 0.332926,0.25519 0.570949,0.62954 0.652503,1.0418 -0.224184,0.0884 -0.456635,0.18914 -0.70349,0.1695 z"
           id="path26480" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26542);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 37.61954,63.040932 c -0.369098,0.005 -0.140899,-0.58775 -0.486447,-0.55328 -0.173337,-0.66117 0.943021,-0.73784 0.945334,-0.0965 0.136834,0.30468 -0.106597,0.70509 -0.458887,0.64974 z"
           id="path26482" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26544);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 37.074526,68.927222 c -0.374767,-0.21164 -0.800908,-0.0198 -1.184423,-0.1633 -0.19245,-0.27378 -0.02185,-0.80117 -0.334175,-1.09416 -0.259412,-0.29313 0.432498,-0.0908 0.59738,-0.007 0.533345,0.26896 0.829877,0.81998 1.12379,1.31189 -0.06752,-0.0158 -0.135048,-0.0317 -0.202572,-0.0475 z"
           id="path26484" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26546);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 35.89148,90.448042 c -0.65432,0.099 -1.13742,-0.419381 -1.531689,-0.86196 0.676096,0.35437 1.388909,0.0011 1.971973,-0.355528 0.53193,-0.18846 -0.314771,0.387289 0.03086,0.681259 0.319612,0.410539 -0.112171,0.604661 -0.471148,0.536229 z"
           id="path26486" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26548);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 33.032051,68.327772 c -0.472406,-0.2743 -0.004,-1.140379 -0.633208,-1.343579 -0.154266,-0.324621 0.405933,-0.249051 0.598068,-0.237721 0.564986,0.0886 1.102684,0.46612 1.316716,1.00666 -0.280257,0.3442 -0.876092,-0.24412 -1.008035,0.28801 -0.04348,0.12159 -0.110214,0.30709 -0.273541,0.28663 z"
           id="path26488" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26550);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 33.695577,89.623984 c -0.713594,-0.085 -1.342531,-0.47489 -1.95268,-0.82614 0.770931,0.0757 1.561144,-0.119571 2.132188,-0.670553 0.175055,-0.0288 -0.311738,0.603682 0.021,0.81525 0.199929,0.266642 0.510763,0.411973 0.787549,0.582221 -0.329949,0.02371 -0.656258,0.10699 -0.988053,0.0992 z"
           id="path26490" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26552);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 31.837292,84.907642 c 0.146708,-0.730989 0.810961,-1.175459 1.511578,-1.282539 0.32835,-0.0984 1.033876,-0.21012 0.411475,0.14359 -0.203924,0.27795 0.05081,1.07811 -0.53399,0.90813 -0.556175,-0.0695 -1.08889,0.17093 -1.512397,0.513321 0.04111,-0.0942 0.08222,-0.18833 0.123334,-0.282502 z"
           id="path26492" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26554);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 32.2886,73.720042 c -0.850466,0.0466 -1.425178,-0.77621 -1.626085,-1.5124 0.465644,0.611961 1.25895,0.430791 1.896858,0.28614 -0.124308,0.0858 -0.534276,0.51751 -0.09852,0.73499 0.385661,0.213771 0.228209,0.56938 -0.172255,0.49127 z"
           id="path26494" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26556);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 30.945013,87.567944 c 0.13201,-0.954313 0.982154,-1.565871 1.761132,-2.015382 -0.331124,0.42912 -0.416172,1.096531 0.08888,1.426271 0.08135,0.352891 -0.457581,0.106479 -0.640787,0.11231 -0.539672,-7.93e-4 -0.919126,0.45088 -1.300179,0.773769 0.03032,-0.099 0.06063,-0.19798 0.09095,-0.296968 z"
           id="path26496" />
        <path
           style="opacity:1;vector-effect:none;fill:url(#radialGradient26558);fill-opacity:1;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
           d="m 30.961549,70.797223 c -0.8083,-0.296881 -0.91843,-1.301251 -0.873676,-2.04363 0.317583,0.72967 1.130878,0.93965 1.844707,1.024489 0.347216,0.13245 -0.445839,0.127061 -0.505943,0.43003 -0.156123,0.17428 -0.18669,0.58321 -0.465088,0.589111 z"
           id="path26498" />
      </g>
    </g>
</symbol>

    <linearGradient
       id="linearGradient31095">
      <stop
         id="stop31091"
         offset="0"
         style="stop-color:#000000;stop-opacity:1" />
      <stop
         style="stop-color:#000000;stop-opacity:0.01324503"
         offset="0.29600534"
         id="stop31115" />
      <stop
         id="stop31121"
         offset="0.31642833"
         style="stop-color:#ffffff;stop-opacity:0" />
      <stop
         id="stop31119"
         offset="0.4929485"
         style="stop-color:#ffffff;stop-opacity:0.76158941" />
      <stop
         style="stop-color:#f3f3f3;stop-opacity:0"
         offset="0.70102847"
         id="stop31123" />
      <stop
         id="stop31117"
         offset="0.7199809"
         style="stop-color:#000000;stop-opacity:0" />
      <stop
         id="stop31093"
         offset="1"
         style="stop-color:#000000;stop-opacity:1" />
    </linearGradient>
    <linearGradient
       gradientUnits="userSpaceOnUse"
       y2="22.542038"
       x2="26.974045"
       y1="11.769716"
       x1="6.3743415"
       id="linearGradient31097-9"
       xlink:href="#linearGradient31095"
       gradientTransform="scale(3.7795276)" />
    <linearGradient
       y2="34.070309"
       x2="35.813248"
       y1="-20.027531"
       x1="-6.8035736"
       gradientTransform="scale(3.7795276)"
       gradientUnits="userSpaceOnUse"
       id="linearGradient31246"
       xlink:href="#linearGradient31095" />
    <linearGradient
       y2="17.203125"
       x2="10.441666"
       y1="16.966888"
       x1="1.6023921"
       gradientUnits="userSpaceOnUse"
       id="linearGradient31248"
       xlink:href="#linearGradient31095" />
    <linearGradient
       y2="34.070309"
       x2="35.813248"
       y1="-20.027531"
       x1="-6.8035736"
       gradientUnits="userSpaceOnUse"
       id="linearGradient31250"
       xlink:href="#linearGradient31095" />
<symbol id="scroll">
    <g
       transform="translate(#{Ribbon::WIDTH/2*Ribbon::SCALE},#{Ribbon::HEIGHT/2*Ribbon::SCALE}) translate(1,2) matrix(0.60824807,0,0,0.60824807,-11.048509,-11.325777)"
       style="stroke-width:1.6440661">
      <path
         style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill-opacity:1;fill-rule:nonzero;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate;stroke:none"
         d="m 6.4254474,7.8480996 c -1.6228406,0 -2.92902,1.3066963 -2.92902,2.9295374 v 13.985192 c 0,1.605558 1.279081,2.899017 2.8778605,2.926436 v 0.0021 h 0.040824 c 0.00349,1.1e-5 0.00684,5.29e-4 0.010335,5.29e-4 0.00349,0 0.00685,-5.29e-4 0.010335,-5.29e-4 H 27.244848 c 0.463145,1.005187 1.475594,1.701186 2.65875,1.701186 1.622843,0 2.929022,-1.306695 2.929022,-2.929535 V 12.477791 c 0,-1.622841 -1.306179,-2.9290199 -2.929022,-2.9290199 H 9.0841998 C 8.6209345,8.5438902 7.6083826,7.8480996 6.4254474,7.8480996 Z"
         id="path31234" />
      <g>
        <path
           transform="scale(0.26458333)"
           id="path31236"
           d="m 34.333984,36.089844 c 0.651217,1.412467 1.023438,2.981895 1.023438,4.644531 v 52.857422 c 0,6.120376 -4.917976,11.047183 -11.033203,11.068363 h 78.648441 c -0.65076,-1.41206 -1.02344,-2.98058 -1.02344,-4.64258 V 47.160156 c 0,-6.133572 4.93869,-11.070312 11.07226,-11.070312 z M 24.091797,104.65234 v 0.008 h 0.154297 c -0.05208,-1.8e-4 -0.102391,-0.007 -0.154297,-0.008 z"
           style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient31246);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:1.33333325;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
        <rect
           style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient31248);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate"
           id="rect31238"
           width="5.8586307"
           height="19.84375"
           x="3.4962797"
           y="7.8482137"
           ry="2.9293153"
           rx="2.9293153" />
        <rect
           rx="2.9293153"
           ry="2.9293153"
           y="9.5486717"
           x="26.974045"
           height="19.84375"
           width="5.8586307"
           id="rect31240"
           style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient31250);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.35277775;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
      </g>
    </g>
</symbol>
    <linearGradient
       y2="-1.8537519"
       x2="1.8537519"
       y1="-0.050462533"
       x1="-2.8116875"
       gradientTransform="matrix(2.6725296,2.6725296,-2.6725296,2.6725296,1.8312192e-7,-3.2753691e-5)"
       gradientUnits="userSpaceOnUse"
       id="linearGradient53032"
       xlink:href="#linearGradient47334" />
    <linearGradient
       id="linearGradient47334">
      <stop
         id="stop47320"
         offset="0"
         style="stop-color:#000000;stop-opacity:1" />
      <stop
         style="stop-color:#000000;stop-opacity:0.01324503"
         offset="0.29600534"
         id="stop47322" />
      <stop
         id="stop47324"
         offset="0.00319751"
         style="stop-color:#ffffff;stop-opacity:0" />
      <stop
         id="stop47326"
         offset="0.4929485"
         style="stop-color:#ffffff;stop-opacity:0.76158941" />
      <stop
         style="stop-color:#f3f3f3;stop-opacity:0"
         offset="0.70102847"
         id="stop47328" />
      <stop
         id="stop47330"
         offset="0.68771511"
         style="stop-color:#000000;stop-opacity:0" />
      <stop
         id="stop47332"
         offset="1"
         style="stop-color:#000000;stop-opacity:1" />
    </linearGradient>
    <linearGradient
       gradientUnits="userSpaceOnUse"
       y2="-2.5159059"
       x2="0.60240114"
       y1="2.6399274"
       x1="-0.34540993"
       id="linearGradient52989"
       xlink:href="#linearGradient47334"
       gradientTransform="translate(-6.2046321e-6,-6.2150561e-6)" />
    <linearGradient
       y2="319.44843"
       x2="367.69556"
       y1="459.85962"
       x1="268.70056"
       gradientTransform="translate(-90.913726,-158.59453)"
       gradientUnits="userSpaceOnUse"
       id="linearGradient48308"
       xlink:href="#linearGradient31095" />
    <linearGradient
       id="linearGradient31095">
      <stop
         style="stop-color:#000000;stop-opacity:1"
         offset="0"
         id="stop31091" />
      <stop
         id="stop31115"
         offset="0.29600534"
         style="stop-color:#000000;stop-opacity:0.01324503" />
      <stop
         style="stop-color:#ffffff;stop-opacity:0"
         offset="0.31642833"
         id="stop31121" />
      <stop
         style="stop-color:#ffffff;stop-opacity:0.76158941"
         offset="0.4929485"
         id="stop31119" />
      <stop
         id="stop31123"
         offset="0.70102847"
         style="stop-color:#f3f3f3;stop-opacity:0" />
      <stop
         style="stop-color:#000000;stop-opacity:0"
         offset="0.7199809"
         id="stop31117" />
      <stop
         style="stop-color:#000000;stop-opacity:1"
         offset="1"
         id="stop31093" />
    </linearGradient>
    <linearGradient
       y2="470.97131"
       x2="231.32497"
       y1="298.2352"
       x1="348.50262"
       gradientTransform="translate(-90.913726,-158.59453)"
       gradientUnits="userSpaceOnUse"
       id="linearGradient48310"
       xlink:href="#linearGradient31095" />
    <linearGradient
       y2="93.87336"
       x2="226.79581"
       y1="70.608948"
       x1="225.77945"
       gradientTransform="matrix(3.5468637,1.305598,-1.305598,3.5468637,-90.913726,-158.59453)"
       gradientUnits="userSpaceOnUse"
       id="linearGradient48312"
       xlink:href="#linearGradient31095" />
    <linearGradient
       y2="-185.59569"
       x2="86.397354"
       y1="-195.57449"
       x1="86.426582"
       gradientUnits="userSpaceOnUse"
       id="linearGradient48314"
       xlink:href="#linearGradient47334"
       gradientTransform="translate(-1.4263463e-4,5.1780628e-5)" />
    <linearGradient
       y2="319.44843"
       x2="367.69556"
       y1="459.85962"
       x1="268.70056"
       gradientTransform="translate(-90.913724,-158.59453)"
       gradientUnits="userSpaceOnUse"
       id="linearGradient48316"
       xlink:href="#linearGradient31095" />
    <linearGradient
       y2="470.97131"
       x2="231.32497"
       y1="298.2352"
       x1="348.50262"
       gradientTransform="translate(-90.913724,-158.59453)"
       gradientUnits="userSpaceOnUse"
       id="linearGradient48318"
       xlink:href="#linearGradient31095" />
    <linearGradient
       y2="93.87336"
       x2="226.79581"
       y1="70.608948"
       x1="225.77945"
       gradientTransform="matrix(3.5468637,1.305598,-1.305598,3.5468637,-90.913724,-158.59453)"
       gradientUnits="userSpaceOnUse"
       id="linearGradient48320"
       xlink:href="#linearGradient31095" />
    <linearGradient
       y2="-185.59569"
       x2="86.397354"
       y1="-195.57449"
       x1="86.426582"
       gradientUnits="userSpaceOnUse"
       id="linearGradient48322"
       xlink:href="#linearGradient47334"
       gradientTransform="translate(-1.4208125e-4,5.3227195e-5)" />
<symbol id ="diamond">
    <g
       id="g52983"
       transform="translate(3.0288462,1.5144231) translate(#{Ribbon::WIDTH/2*Ribbon::SCALE},#{Ribbon::HEIGHT/2*Ribbon::SCALE}) scale(2.5) translate(-4.1164686e-8,8.6609417e-6)">
      <rect
         style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate"
         id="rect52980"
         width="2.9056914"
         height="2.9056919"
         x="-1.4528438"
         y="-1.4528477"
         transform="rotate(45)" />
      <path
         id="rect52987"
         transform="scale(0.26458333)"
         d="M 0,-7.765625 -7.765625,0 0,7.765625 7.765625,0 Z M 0,-5.0507812 5.0507812,0 0,5.0507812 -5.0507812,0 Z"
         style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient53032);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.99999994px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
      <rect
         transform="rotate(45)"
         y="-0.94494218"
         x="-0.9449383"
         height="1.8898808"
         width="1.8898804"
         id="rect52985"
         style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient52989);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
    </g>
</symbol>
<symbol id="swords">
    <g
       id="use48276"
       style="stroke-width:17.28150558"
       transform="translate(1.5144231, 1.5144231) translate(#{Ribbon::WIDTH/2*Ribbon::SCALE},#{Ribbon::HEIGHT/2*Ribbon::SCALE}) scale(4) matrix(0.05786533,0,0,0.05786533,-5.3861126,-4.1405573)">
      <g
         id="g48290"
         transform="translate(-24.054257,-41.961316)">
        <path
           style="fill-rule:evenodd;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
           d="m 38.553718,63.410599 v 4.852416 0.434083 3.973918 C 61.249146,105.94678 110.78185,130.91347 148.05246,146.99929 l -1.80402,4.901 c -0.5606,1.52293 -0.31309,3.00583 0.555,3.32538 0.8681,0.31954 2.01806,-0.64903 2.57865,-2.17197 l 1.62109,-4.40438 40.18153,14.79083 c 1.52294,0.56059 3.1999,-0.21443 3.76049,-1.73736 l 0.58756,-1.59629 c 0.5606,-1.52293 -0.2139,-3.20041 -1.73684,-3.76101 l -40.18101,-14.79031 1.21285,-3.2954 c 0.56059,-1.52294 0.31309,-3.00635 -0.55501,-3.3259 -0.86808,-0.31954 -2.01806,0.64954 -2.57865,2.17248 l -1.4733,4.00234 C 118.73877,130.9078 57.386479,93.43686 40.821281,67.422757 39.950284,66.054938 39.165995,64.70937 38.553718,63.410599 Z m 2.267563,8.667171 c 0.05448,0.0807 0.0966,0.158366 0.151929,0.239262 -0.05177,-0.07569 -0.100904,-0.150823 -0.151929,-0.226343 z"
           id="path48278" />
        <g
           id="g48288">
          <path
             style="opacity:1;vector-effect:none;fill:url(#linearGradient48308);fill-opacity:1;fill-rule:evenodd;stroke:none;stroke-width:0.99999994px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
             d="m 54.800781,81.068359 v 18.339844 1.640627 15.01953 C 140.5785,241.83462 327.78916,336.19729 468.6543,396.99414 l 4.3125,-11.71484 c -3.66355,-1.21926 -7.41314,-2.51531 -11.33594,-3.9668 -8.69071,-3.21568 -17.84263,-6.85547 -27.37109,-10.87891 -9.52846,-4.02343 -19.43318,-8.42913 -29.625,-13.17382 -10.19183,-4.7447 -20.67077,-9.82952 -31.35157,-15.20899 -10.68081,-5.37946 -21.56319,-11.05469 -32.55859,-16.98242 -10.9954,-5.92773 -22.10464,-12.10854 -33.24023,-18.49805 -11.13561,-6.38951 -22.29702,-12.98716 -33.39844,-19.75195 -11.10142,-6.76479 -22.1423,-13.69643 -33.03516,-20.75 -10.89285,-7.05357 -21.63854,-14.22852 -32.14844,-21.48438 -10.50991,-7.25586 -20.78375,-14.59123 -30.73632,-21.96289 -9.95257,-7.37165 -19.58385,-14.78069 -28.80469,-22.18164 -9.22084,-7.40095 -18.03292,-14.79492 -26.34766,-22.13867 -8.31473,-7.34375 -16.13099,-14.63783 -23.365232,-21.83789 -3.61712,-3.60003 -7.089997,-7.17672 -10.404297,-10.72461 -3.31429,-3.54789 -6.471268,-7.06585 -9.460938,-10.55078 -2.98968,-3.48493 -5.811818,-6.93649 -8.455078,-10.34766 -2.64326,-3.41116 -5.107783,-6.78278 -7.382813,-10.10937 -0.195659,-0.28609 -0.381368,-0.57004 -0.574218,-0.85547 V 96.232422 c -3.29196,-5.16971 -6.256193,-10.255323 -8.570313,-15.164063 z"
             transform="matrix(0.26458333,0,0,0.26458333,24.054257,41.961316)"
             id="path48280" />
          <path
             style="opacity:1;vector-effect:none;fill:url(#linearGradient48310);fill-opacity:1;fill-rule:evenodd;stroke:none;stroke-width:0.99999994px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
             d="m 63.371094,96.232422 v 17.593748 c 0.20589,0.30499 0.365109,0.59855 0.574218,0.9043 2.27503,3.32659 4.739553,6.69821 7.382813,10.10937 2.64326,3.41117 5.465398,6.86273 8.455078,10.34766 2.98967,3.48493 6.146648,7.00289 9.460938,10.55078 3.3143,3.54789 6.787177,7.12458 10.404297,10.72461 7.234242,7.20006 15.050502,14.49414 23.365232,21.83789 8.31474,7.34375 17.12682,14.73772 26.34766,22.13867 9.22084,7.40095 18.85212,14.80999 28.80469,22.18164 9.95257,7.37166 20.22641,14.70703 30.73632,21.96289 10.5099,7.25586 21.25559,14.43081 32.14844,21.48438 10.89286,7.05357 21.93374,13.98521 33.03516,20.75 11.10142,6.76479 22.26283,13.36244 33.39844,19.75195 11.13559,6.38951 22.24483,12.57032 33.24023,18.49805 10.9954,5.92773 21.87778,11.60296 32.55859,16.98242 10.6808,5.37947 21.15974,10.46429 31.35157,15.20899 10.19182,4.74469 20.09654,9.15039 29.625,13.17382 9.52846,4.02344 18.68038,7.66323 27.37109,10.87891 3.9228,1.45149 7.67239,2.74754 11.33594,3.9668 l 3.88281,-10.54883 C 357.86239,336.17589 125.97971,194.55344 63.371094,96.232422 Z"
             transform="matrix(0.26458333,0,0,0.26458333,24.054257,41.961316)"
             id="path48282" />
          <path
             style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient48312);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.99999994px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate"
             d="m 489.67773,376.41797 -9.86914,26.8125 151.86524,55.90039 c 5.75599,2.11878 12.09412,-0.80848 14.21289,-6.56445 l 2.2207,-6.03321 c 2.11877,-5.75598 -0.80846,-12.09606 -6.56445,-14.21484 z"
             transform="matrix(0.26458333,0,0,0.26458333,24.054257,41.961316)"
             id="path48284" />
          <path
             transform="rotate(110.20863)"
             style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient48314);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate"
             d="m 76.264925,-193.05724 h 15.764382 c 1.622836,0 2.929307,0.7447 2.929307,1.66974 0,0.92503 -1.306471,1.66973 -2.929307,1.66973 H 76.264925 c -1.622837,0 -2.929308,-0.7447 -2.929308,-1.66973 0,-0.92504 1.306471,-1.66974 2.929308,-1.66974 z"
             id="path48286" />
        </g>
      </g>
      <g
         id="g48304"
         transform="matrix(-1,0,0,1,210.21452,-41.961316)">
        <path
           style="fill-rule:evenodd;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
           d="m 38.553718,63.410599 v 4.852416 0.434083 3.973918 C 61.249146,105.94678 110.78185,130.91347 148.05246,146.99929 l -1.80402,4.901 c -0.5606,1.52293 -0.31309,3.00583 0.555,3.32538 0.8681,0.31954 2.01806,-0.64903 2.57865,-2.17197 l 1.62109,-4.40438 40.18153,14.79083 c 1.52294,0.56059 3.1999,-0.21443 3.76049,-1.73736 l 0.58756,-1.59629 c 0.5606,-1.52293 -0.2139,-3.20041 -1.73684,-3.76101 l -40.18101,-14.79031 1.21285,-3.2954 c 0.56059,-1.52294 0.31309,-3.00635 -0.55501,-3.3259 -0.86808,-0.31954 -2.01806,0.64954 -2.57865,2.17248 l -1.4733,4.00234 C 118.73877,130.9078 57.386479,93.43686 40.821281,67.422757 39.950284,66.054938 39.165995,64.70937 38.553718,63.410599 Z m 2.267563,8.667171 c 0.05448,0.0807 0.0966,0.158366 0.151929,0.239262 -0.05177,-0.07569 -0.100904,-0.150823 -0.151929,-0.226343 z"
           id="path48292" />
        <g
           id="g48302">
          <path
             style="opacity:1;vector-effect:none;fill:url(#linearGradient48316);fill-opacity:1;fill-rule:evenodd;stroke:none;stroke-width:0.99999994px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
             d="m 54.800781,81.068359 v 18.339844 1.640627 15.01953 C 140.5785,241.83462 327.78916,336.19729 468.6543,396.99414 l 4.3125,-11.71484 c -3.66355,-1.21926 -7.41314,-2.51531 -11.33594,-3.9668 -8.69071,-3.21568 -17.84263,-6.85547 -27.37109,-10.87891 -9.52846,-4.02343 -19.43318,-8.42913 -29.625,-13.17382 -10.19183,-4.7447 -20.67077,-9.82952 -31.35157,-15.20899 -10.68081,-5.37946 -21.56319,-11.05469 -32.55859,-16.98242 -10.9954,-5.92773 -22.10464,-12.10854 -33.24023,-18.49805 -11.13561,-6.38951 -22.29702,-12.98716 -33.39844,-19.75195 -11.10142,-6.76479 -22.1423,-13.69643 -33.03516,-20.75 -10.89285,-7.05357 -21.63854,-14.22852 -32.14844,-21.48438 -10.50991,-7.25586 -20.78375,-14.59123 -30.73632,-21.96289 -9.95257,-7.37165 -19.58385,-14.78069 -28.80469,-22.18164 -9.22084,-7.40095 -18.03292,-14.79492 -26.34766,-22.13867 -8.31473,-7.34375 -16.13099,-14.63783 -23.365232,-21.83789 -3.61712,-3.60003 -7.089997,-7.17672 -10.404297,-10.72461 -3.31429,-3.54789 -6.471268,-7.06585 -9.460938,-10.55078 -2.98968,-3.48493 -5.811818,-6.93649 -8.455078,-10.34766 -2.64326,-3.41116 -5.107783,-6.78278 -7.382813,-10.10937 -0.195659,-0.28609 -0.381368,-0.57004 -0.574218,-0.85547 V 96.232422 c -3.29196,-5.16971 -6.256193,-10.255323 -8.570313,-15.164063 z"
             transform="matrix(0.26458333,0,0,0.26458333,24.054257,41.961316)"
             id="path48294" />
          <path
             style="opacity:1;vector-effect:none;fill:url(#linearGradient48318);fill-opacity:1;fill-rule:evenodd;stroke:none;stroke-width:0.99999994px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
             d="m 63.371094,96.232422 v 17.593748 c 0.20589,0.30499 0.365109,0.59855 0.574218,0.9043 2.27503,3.32659 4.739553,6.69821 7.382813,10.10937 2.64326,3.41117 5.465398,6.86273 8.455078,10.34766 2.98967,3.48493 6.146648,7.00289 9.460938,10.55078 3.3143,3.54789 6.787177,7.12458 10.404297,10.72461 7.234242,7.20006 15.050502,14.49414 23.365232,21.83789 8.31474,7.34375 17.12682,14.73772 26.34766,22.13867 9.22084,7.40095 18.85212,14.80999 28.80469,22.18164 9.95257,7.37166 20.22641,14.70703 30.73632,21.96289 10.5099,7.25586 21.25559,14.43081 32.14844,21.48438 10.89286,7.05357 21.93374,13.98521 33.03516,20.75 11.10142,6.76479 22.26283,13.36244 33.39844,19.75195 11.13559,6.38951 22.24483,12.57032 33.24023,18.49805 10.9954,5.92773 21.87778,11.60296 32.55859,16.98242 10.6808,5.37947 21.15974,10.46429 31.35157,15.20899 10.19182,4.74469 20.09654,9.15039 29.625,13.17382 9.52846,4.02344 18.68038,7.66323 27.37109,10.87891 3.9228,1.45149 7.67239,2.74754 11.33594,3.9668 l 3.88281,-10.54883 C 357.86239,336.17589 125.97971,194.55344 63.371094,96.232422 Z"
             transform="matrix(0.26458333,0,0,0.26458333,24.054257,41.961316)"
             id="path48296" />
          <path
             style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient48320);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.99999994px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate"
             d="m 489.67773,376.41797 -9.86914,26.8125 151.86524,55.90039 c 5.75599,2.11878 12.09412,-0.80848 14.21289,-6.56445 l 2.2207,-6.03321 c 2.11877,-5.75598 -0.80846,-12.09606 -6.56445,-14.21484 z"
             transform="matrix(0.26458333,0,0,0.26458333,24.054257,41.961316)"
             id="path48298" />
          <path
             transform="rotate(110.20863)"
             style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#linearGradient48322);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate"
             d="m 76.264925,-193.05724 h 15.764382 c 1.622836,0 2.929307,0.7447 2.929307,1.66974 0,0.92503 -1.306471,1.66973 -2.929307,1.66973 H 76.264925 c -1.622837,0 -2.929308,-0.7447 -2.929308,-1.66973 0,-0.92504 1.306471,-1.66974 2.929308,-1.66974 z"
             id="path48300" />
        </g>
      </g>
    </g>
</symbol>
<symbol id = "swords_laurel">
      <use
         transform="translate(1.5144231, 1.5144231) translate(#{Ribbon::WIDTH/2*Ribbon::SCALE},#{Ribbon::HEIGHT/2*Ribbon::SCALE}) matrix(-1,0,0,1,0,0) "
         xlink:href="#half_laurel" />
      <use
         transform="translate(1.5144231, 1.5144231) translate(#{Ribbon::WIDTH/2*Ribbon::SCALE},#{Ribbon::HEIGHT/2*Ribbon::SCALE})"
         xlink:href="#half_laurel" />
      <use
         xlink:href="#swords" />
</symbol>
<symbol id = "swords_diamonds">
      <use
         x="#{Ribbon::WIDTH/4*Ribbon::SCALE}"
         xlink:href="#diamond" />
      <use
         x="#{-Ribbon::WIDTH/4*Ribbon::SCALE}"
         xlink:href="#diamond" />
      <use
         xlink:href="#swords_laurel" />
</symbol>
    <linearGradient
       id="linearGradient62600">
      <stop
         id="stop62596"
         offset="0"
         style="stop-color:#ffffff;stop-opacity:0.58278143" />
      <stop
         style="stop-color:#f6f6f6;stop-opacity:0.00784314"
         offset="0.53631157"
         id="stop63870" />
      <stop
         id="stop63872"
         offset="0.63382274"
         style="stop-color:#000000;stop-opacity:0" />
      <stop
         id="stop62598"
         offset="1"
         style="stop-color:#000000;stop-opacity:0.45695364" />
    </linearGradient>
    <radialGradient
       r="4.277398"
       fy="-1.6716315"
       fx="4.9630837e-24"
       cy="-1.6716315"
       cx="4.9630837e-24"
       gradientTransform="matrix(4.5588461,0,0,4.7950798,6.6365582e-8,1.5352894)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient63878"
       xlink:href="#linearGradient62600" />
    <radialGradient
       r="1.4108067"
       fy="-0.61495411"
       fx="0.1013199"
       cy="-0.31807974"
       cx="0.03039586"
       gradientTransform="matrix(1.6320944,0,-1.6232672e-6,1.5596523,1.873893e-8,0)"
       gradientUnits="userSpaceOnUse"
       id="radialGradient65039"
       xlink:href="#linearGradient62600" />

<symbol id="star_of_grayson">
    <g
       transform="translate(#{Ribbon::WIDTH/2*Ribbon::SCALE},#{Ribbon::HEIGHT/2*Ribbon::SCALE}) translate(1.5, 1.5) scale(2.5)"
       id="g62590">
      <path
         style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate"
         id="path62587"
         d="M 1.9056163e-7,-4.3873048 C 0.06680439,-4.3873048 0.49185366,-2.4551662 0.55698294,-2.4403008 c 0.0651293,0.014865 1.28640896,-1.5415095 1.34659746,-1.5125242 0.060188,0.028985 -0.3951789,1.954204 -0.3429493,1.9958557 0.05223,0.041652 1.8278503,-0.8307001 1.869502,-0.7784704 0.041652,0.05223 -1.2039411,1.5892152 -1.1749559,1.6494037 0.028985,0.060188 2.0072635,0.04464 2.0221288,0.10976892 C 4.2921713,-0.91113781 2.5030578,-0.06680411 2.5030578,9.0175003e-8 2.5030578,0.06680428 4.2921713,0.91113796 4.2773059,0.97626723 4.2624406,1.0413965 2.2841624,1.0258476 2.2551771,1.0860361 2.2261918,1.1462246 3.4717847,2.6832102 3.430133,2.7354398 3.3884813,2.7876695 1.6128606,1.9153176 1.5606309,1.9569694 1.5084013,1.9986211 1.9637687,3.9238398 1.9035802,3.952825 1.8433917,3.9818103 0.62211196,2.4254355 0.55698269,2.4403008 0.49185341,2.4551662 0.06680415,4.3873047 -4.4553126e-8,4.3873047 -0.06680424,4.3873047 -0.49185352,2.4551661 -0.55698279,2.4403008 -0.62211207,2.4254354 -1.8433917,3.9818102 -1.9035802,3.9528249 -1.9637687,3.9238397 -1.5084014,1.9986209 -1.560631,1.9569692 -1.6128606,1.9153175 -3.3884813,2.7876693 -3.430133,2.7354397 -3.4717847,2.68321 -2.2261918,1.1462244 -2.2551771,1.0860359 -2.2841623,1.0258474 -4.2624405,1.0413963 -4.2773058,0.976267 -4.2921712,0.91113773 -2.5030576,0.06680403 -2.5030576,-1.6783259e-7 -2.5030576,-0.06680436 -4.2921711,-0.91113804 -4.2773058,-0.97626731 c 0.014865,-0.0651293 1.9931436,-0.0495804 2.0221289,-0.10976889 0.028985,-0.060189 -1.2166077,-1.5971741 -1.174956,-1.6494037 0.041652,-0.05223 1.8172725,0.8201222 1.8695021,0.7784705 0.05223,-0.041652 -0.4031377,-1.9668705 -0.3429492,-1.9958557 0.060188,-0.028985 1.28146818,1.5273895 1.34659746,1.5125242 0.0651293,-0.014865 0.49017854,-1.9470039 0.55698273056163,-1.9470039 z" />
      <path
         id="path62594"
         transform="scale(0.26458333)"
         d="M 0 -16.582031 C -0.25248829 -16.582031 -1.8593109 -9.2788402 -2.1054688 -9.2226562 C -2.3516266 -9.1664723 -6.9678284 -15.049004 -7.1953125 -14.939453 C -7.4227966 -14.829903 -5.7010342 -7.5539082 -5.8984375 -7.3964844 C -6.0958408 -7.2390605 -12.80742 -10.535294 -12.964844 -10.337891 C -13.122268 -10.140487 -8.4138869 -4.3329528 -8.5234375 -4.1054688 C -8.6329881 -3.8779847 -16.109832 -3.935611 -16.166016 -3.6894531 C -16.2222 -3.4432952 -9.4609375 -0.25248829 -9.4609375 0 C -9.4609375 0.2524883 -16.2222 3.4432952 -16.166016 3.6894531 C -16.109832 3.935611 -8.6329881 3.8779847 -8.5234375 4.1054688 C -8.4138869 4.3329529 -13.122268 10.140487 -12.964844 10.337891 C -12.80742 10.535294 -6.0958408 7.2390605 -5.8984375 7.3964844 C -5.7010342 7.5539083 -7.4227966 14.829903 -7.1953125 14.939453 C -6.9678284 15.049004 -2.3516266 9.1664723 -2.1054688 9.2226562 C -1.8593109 9.2788402 -0.2524883 16.582031 0 16.582031 C 0.25248829 16.582031 1.8593109 9.2788402 2.1054688 9.2226562 C 2.3516266 9.1664723 6.9678284 15.049004 7.1953125 14.939453 C 7.4227966 14.829903 5.7010342 7.5539082 5.8984375 7.3964844 C 6.0958408 7.2390605 12.80742 10.535294 12.964844 10.337891 C 13.122268 10.140487 8.4138869 4.3329528 8.5234375 4.1054688 C 8.6329881 3.8779847 16.109832 3.935611 16.166016 3.6894531 C 16.2222 3.4432952 9.4609375 0.25248829 9.4609375 0 C 9.4609375 -0.2524883 16.2222 -3.4432952 16.166016 -3.6894531 C 16.109832 -3.935611 8.6329881 -3.8779847 8.5234375 -4.1054688 C 8.4138869 -4.3329529 13.122268 -10.140487 12.964844 -10.337891 C 12.80742 -10.535294 6.0958408 -7.2390605 5.8984375 -7.3964844 C 5.7010342 -7.5539083 7.4227966 -14.829903 7.1953125 -14.939453 C 6.9678284 -15.049004 2.3516266 -9.1664723 2.1054688 -9.2226562 C 1.8593109 -9.2788402 0.2524883 -16.582031 0 -16.582031 z M 0 -5.3320312 A 5.3321826 5.3321826 0 0 1 5.3320312 0 A 5.3321826 5.3321826 0 0 1 0 5.3320312 A 5.3321826 5.3321826 0 0 1 -5.3320312 0 A 5.3321826 5.3321826 0 0 1 0 -5.3320312 z "
         style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#radialGradient63878);fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:0.99999994px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
      <circle
         r="1.4108067"
         cy="-3.8828727e-08"
         cx="7.3004252e-08"
         id="path63874"
         style="color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:url(#radialGradient65039);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:0.26458332px;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:0.08609272;marker:none;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate" />
    </g>

</symbol>
		<filter height="116%" width="116%" y="-8%" x="-8%"  id="shadow">
		  <feGaussianBlur in="SourceAlpha" stdDeviation="2" result="blurred" />
		  <feOffset dx="0" dy="2" in="blurred" result="shadow"/>
		  <feMerge>
		    <feMergeNode in="shadow" />
		    <feMergeNode in="SourceGraphic" />
		  </feMerge>
		</filter>
	      </defs>
EOS
  end
  ribbon.draw(out)
  out << "<use xlink:href=\"\#ribbon-shade\" />"
  ribbon.drawDevices(n, out)
  out << "</svg>"
end

RIBBONS.each_pair.select{|key, ribbon| not ribbon.nil?}.to_a.each do |key, ribbon|
  ribbon.devices.values(15).each do |n|
    open("ribbons/#{key}-#{n}.svg",'w') do |out|
      ribbon_out(ribbon, n, out, true)
    end
  end
end

