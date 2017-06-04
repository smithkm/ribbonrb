require 'set'

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
  
  def initialize(single: "#star", group: "#star_laurel", colour: "#a05a2c")
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
  def initialize(single: "#star", group: "#star_laurel", colour: "#a05a2c", special: "#fleet_e", special_colour: "#E3DEDB")
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
end

RIBBONS = {}

RIBBONS['PMV']=VerticalRibbon.new(1, "Parliamentary Medal of Valour", [[Colours::CRIMSON, Ribbon::WIDTH/3.0],[Colours::NAVY_BLUE,Ribbon::WIDTH/3.0],[Colours::WHITE,Ribbon::WIDTH/3.0]])
RIBBONS['QCB']=SolidRibbon.new(2, "Queen's Cross for Bravery", Colours::FOREST_GREEN)
RIBBONS['KSK']=MirrorRibbon.new(3, "Most Noble Order of the Star Kingdom", [[Colours::GOLD, 2],[Colours::ROYAL_BLUE, 31]], devices: DevicesNone.new)
RIBBONS['GCR']=MirrorRibbon.new(4, "Knight Grand Cross, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger, devices: DevicesOne.new("#crown", "#888888"))
RIBBONS['GCE']=MirrorRibbon.new(5, "Knight Grand Cross, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth, devices: DevicesOne.new("#crown", "#888888"))

RIBBONS['OM']=VerticalRibbon.new(6, "Most Distinguished Order of Merit", [[Colours::GOLD, 2],[Colours::ROYAL_BLUE,15.5],[Colours::WHITE,15.5],[Colours::GOLD,2]], devices: DevicesNone.new)
RIBBONS['KDR']=MirrorRibbon.new(7,  "Knight Commander, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['KDE']=MirrorRibbon.new(8,  "Knight Commander, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth, devices: DevicesNone.new)
RIBBONS['KCR']=MirrorRibbon.new(9,  "Knight Companion, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['KCE']=MirrorRibbon.new(10, "Knight Companion, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['MC']=SolidRibbon.new(11, "Manticore Cross", Colours::BLOOD_RED)
RIBBONS['OC']=SolidRibbon.new(12, "Osterman Cross", Colours::NAVY_BLUE)

RIBBONS['KR']=MirrorRibbon.new(13, "Knight, King Roger", [[Colours::GOLD, 1],[Colours::SCARLET, 33]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['KE']=MirrorRibbon.new(14, "Knight, Queen Elizabeth", [[Colours::GOLD, 1],[Colours::SILVER, 33]], set: :order_queen_elizabeth, devices: DevicesNone.new)
RIBBONS['CR']=MirrorRibbon.new(15, "Companion, King Roger", [[Colours::GOLD, 1],[Colours::SCARLET, 33]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['CE']=MirrorRibbon.new(16, "Companion, Queen Elizabeth", [[Colours::GOLD, 1],[Colours::SILVER, 33]], set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['SC']=MirrorRibbon.new(17, "Saganami Cross", [[Colours::WHITE, 5],[Colours::SCARLET, 25]])
RIBBONS['DGC']=MirrorRibbon.new(18, "Distinguished Gallantry Cross", [[Colours::NAVY_BLUE, 12],[Colours::PURPLE, 4],[Colours::NAVY_BLUE, 3]])

RIBBONS['OR']=SolidRibbon.new(19, "Companion, King Roger", Colours::SCARLET, set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['OE']=SolidRibbon.new(20, "Companion, Queen Elizabeth", Colours::SILVER, set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['OG']=HorizontalRibbon.new(21, "Order of Gallantry", [[Colours::LIGHT_BLUE, 3],[Colours::WHITE, 2]])

RIBBONS['NS']=MirrorRibbon.new(22, "Navy Star", [[Colours::NAVY_BLUE, 12],[Colours::PURPLE, 4],[Colours::WHITE, 3]])

RIBBONS['DSO']=MirrorRibbon.new(23, "Distinguished Service Order", [[Colours::NAVY_BLUE, 6],[Colours::BLOOD_RED,23]])

RIBBONS['MR']=SolidRibbon.new(24, "Member, King Roger", Colours::SCARLET, set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['ME']=SolidRibbon.new(25, "Member, Queen Elizabeth", Colours::SILVER, set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['MT']=nil # 26, Monarch's Thanks, not a ribbon

RIBBONS['CGM']=MirrorRibbon.new(27, "Conspicuous Gallantry Medal", [[Colours::NAVY_BLUE, 8.5],[Colours::WHITE,4],[Colours::NAVY_BLUE, 10]])

RIBBONS['GS']=MirrorRibbon.new(28, "The Gryphon Star", [[Colours::FOREST_GREEN, 9],[Colours::WHITE,5],[Colours::FOREST_GREEN, 7]])

RIBBONS['OCN']=MirrorRibbon.new(29, "Order of the Crown for Naval Service", [[Colours::NAVY_BLUE, 15.5],[Colours::BLOOD_RED,4]])

RIBBONS['WS']=nil # 30, Wound Stripe, not a ribbon

RIBBONS['QBM']=MirrorRibbon.new(31, "Queen's Bravery Medal", [[Colours::CRIMSON,2],[Colours::FOREST_GREEN,10.5],[Colours::CRIMSON,4],[Colours::WHITE,2]])

RIBBONS['SXC']=MirrorRibbon.new(32, "Sphinx Cross", [[Colours::PURPLE,10],[Colours::WHITE,3],[Colours::CRIMSON,3],[Colours::WHITE,3]])

RIBBONS['RHDSM']=MirrorRibbon.new(33, "Royal Household Distinguished Service Medal", [[Colours::SILVER,3],[Colours::GOLD,3],[Colours::ROYAL_BLUE,nil]], devices: DevicesNone.new)

RIBBONS['MiD']=nil # 34, Mentioned in Dispatches, not a ribbon

RIBBONS['RM']=MirrorRibbon.new(35, "Medal, King Roger", [[Colours::SCARLET,(Ribbon::WIDTH-2)/2],[Colours::GOLD,2]], set: :order_king_roger, devices: DevicesNone.new)
RIBBONS['EM']=MirrorRibbon.new(36, "Medal, Queen Elizabeth", [[Colours::SILVER,(Ribbon::WIDTH-2)/2],[Colours::GOLD,2]], set: :order_queen_elizabeth, devices: DevicesNone.new)

RIBBONS['CBM']=MirrorRibbon.new(37, "Conspicuous Bravery Medal", [[Colours::FOREST_GREEN,12.5],[Colours::WHITE,4],[Colours::CRIMSON,2]])

RIBBONS['CSM']=MirrorRibbon.new(38, "Conspicuous Service Medal", [[Colours::SCARLET,2],[Colours::EMERALD,8],[Colours::SCARLET,15]])
RIBBONS['MSM']=MirrorRibbon.new(39, "Meritorious Service Medal", [[Colours::EMERALD,2],[Colours::SCARLET,8],[Colours::EMERALD,15]])


RIBBONS['NCD']=MirrorRibbon.new(40, "Navy Commendation Decoration", [[Colours::SCARLET,4.5],[Colours::EMERALD,3],[Colours::PURPLE,2],[Colours::EMERALD,3],[Colours::SCARLET,nil]])
RIBBONS['NAM']=MirrorRibbon.new(41, "Navy Achievement Medal", [[Colours::PURPLE,4.5],[Colours::EMERALD,3],[Colours::SCARLET,2],[Colours::EMERALD,3],[Colours::PURPLE,nil]])
RIBBONS['MAM']=MirrorRibbon.new(41, "Marine Achievement Medal", [[Colours::PURPLE,4.5],[Colours::EMERALD,3],[Colours::SCARLET,2],[Colours::EMERALD,3],[Colours::PURPLE,nil]])

RIBBONS['LHC']=nil # 42, List of Honour, Unit Citation
RIBBONS['RUC']=nil # 43, Royal Unit Citation for Gallantry, Unit Citation
RIBBONS['PUC']=nil # 43, Protector's Citation for Gallantry, Unit Citation
RIBBONS['RMU']=nil # 44, Royal Meritorious Unit Citation, Unit Citation
RIBBONS['MUA']=nil # 44, Naval Meritorious Unit Award, Unit Citation

RIBBONS['FEA']=MirrorRibbon.new(45, "Fleet Excellence Award", [[Colours::CRIMSON,2],[Colours::GOLD, 2],[Colours::SPACE_BLACK, nil]], devices: DevicesSpecialWithStars.new)
RIBBONS['FEAG']=MirrorRibbon.new(45, "Fleet Excellence Award in Gold", [[Colours::CRIMSON,2],[Colours::GOLD, 2],[Colours::SPACE_BLACK, nil]], devices: DevicesSpecialWithStars.new(special_colour: "#decd87"))

RIBBONS['POW']=MirrorRibbon.new(46, "Prisoner of War Medal", [[Colours::GOLD,2],[Colours::CHARCOAL_GREY, 11.5],[Colours::CRIMSON,nil]])

# 47 No Abbr Survivor's Cross

RIBBONS['SAPC']=MirrorRibbon.new(48, "Silesian Anti-Piracy Campaign Medal", [[Colours::SCARLET,5],[Colours::ROYAL_BLUE,11],[Colours::GOLD,3]])

RIBBONS['MOM']=MirrorRibbon.new(49, "Masadan Occupation Medal", [[Colours::CRIMSON,4],[Colours::GOLD,3.8],[Colours::CRIMSON,2],[Colours::GOLD,3.8],[Colours::CRIMSON,2],[Colours::GOLD,3.8]])

RIBBONS['HWC']=MirrorRibbon.new(50, "Havenite War Campaign Medal", [[Colours::BLOOD_RED,2],[Colours::FOREST_GREEN,9.5],[Colours::WHITE,4],[Colours::SPACE_BLACK,nil]])
RIBBONS['HOSM']=MirrorRibbon.new(51, "Havenite Operational Service Medal", [[Colours::BLOOD_RED,2],[Colours::FOREST_GREEN,9.5],[Colours::SPACE_BLACK,4],[Colours::GOLD,nil]])

# 52 No Abbr Manticore and Havenite 1905-1922 War Medal

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

RIBBONS['GCM']=MirrorRibbon.new(59, "Good Conduct Medal", [[Colours::ORANGE,7.5],[Colours::CRIMSON,3],[Colours::ORANGE,nil]])

RIBBONS['SSD']=MirrorRibbon.new(60, "Space Service Deployment Ribbon", [[Colours::GOLD,4],[Colours::SPACE_BLACK,nil]], devices: DevicesNone.new)

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

RIBBONS.each_pair.select{|key, ribbon| not ribbon.nil?}.to_a.sort{|p1, p2| p1[1].order <=> p2[1].order}.each do |key, ribbon|
  ribbon.devices.values(15).each do |n|
    open("ribbons/#{key}-#{n}.svg",'w') do |out|
      ribbon_out(ribbon, n, out, true)
    end
  end
end

