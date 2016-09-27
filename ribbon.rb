require 'set'

class Ribbon

  WIDTH=35
  HEIGHT=9

  SCALE=3
  
  attr_reader :order
  attr_reader :name
  attr_reader :set
  
  def initialize(order, name, set: nil)
    @order=order
    @name=name
    @set=set
  end
  
  def drawDevices(n, out)
    device = "#star"
    positions=[]
    case n
    when 2
      positions=[0]
    when 3
      positions=[-WIDTH/6.0, WIDTH/6.0]
    when 4
      positions=[-WIDTH/4.0, 0, WIDTH/4.0]
    when 5
      device="#star_laurel"
      positions=[0]
    when 10
      device="#star_laurel"
      positions=[-WIDTH/6.0, WIDTH/6.0]
    when 15
      device="#star_laurel"
      positions=[-WIDTH/3.25, 0, WIDTH/3.25] # Push them out a bit as they are fairly wide
    end
    positions.each do |x|
      out<< "<use x=\"#{x*SCALE}\" xlink:href=\"#{device}\" class=\"device\" />"
    end
  end
end

class SolidRibbon < Ribbon
  
  attr_reader :colour
  
  def initialize(order, name, colour, set: nil)
    super(order, name, set: set)
    @colour=colour
  end
  
  def draw(out)
    out << "<rect width=\"#{WIDTH*SCALE}\" height=\"#{HEIGHT*SCALE}\" style=\"fill:rgb(#{colour.join(", ")});\"/>"
  end

end

class VerticalRibbon < Ribbon
  attr_reader :colours
  
  def initialize(order, name, colours, set: nil)
    super(order, name, set: set)
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
  
  def initialize(order, name, colours, set: nil)
    
    side_colours = colours[0..-2]
    middle_colour,middle_width = colours[-1]
    
    mcolours=[]+side_colours
    mcolours<<[middle_colour, WIDTH-2*side_colours.map{|c,w|w}.inject(0,:+)]
    mcolours+=side_colours.reverse
    
    super(order, name, mcolours, set: set)
  end

end

class HorizontalRibbon < Ribbon
  attr_reader :colours
  
  def initialize(order, name, colours, set: nil)
    super(order, name, set: set)
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
RIBBONS['KSK']=MirrorRibbon.new(3, "Most Noble Order of the Star Kingdom", [[Colours::GOLD, 2],[Colours::ROYAL_BLUE, 31]])
RIBBONS['GCR']=MirrorRibbon.new(4, "Knight Grand Cross, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger)
RIBBONS['GCE']=MirrorRibbon.new(5, "Knight Grand Cross, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth)
class << RIBBONS['GCR']
  def drawDevices(n, out)
    out<< "<use xlink:href=\"\#crown\" class=\"device\" >"
  end
end
class << RIBBONS['GCE']
  def drawDevices(n, out)
    out<< "<use xlink:href=\"\#crown\" class=\"device\">"
  end
end

RIBBONS['OM']=VerticalRibbon.new(6, "Most Distinguished Order of Merit", [[Colours::GOLD, 2],[Colours::ROYAL_BLUE,15.5],[Colours::WHITE,15.5],[Colours::GOLD,2]])
RIBBONS['KDR']=MirrorRibbon.new(7,  "Knight Commander, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger)
RIBBONS['KDE']=MirrorRibbon.new(8,  "Knight Commander, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth)
RIBBONS['KCR']=MirrorRibbon.new(9,  "Knight Companion, King Roger", [[Colours::GOLD, 2],[Colours::SCARLET, 31]], set: :order_king_roger)
RIBBONS['KCE']=MirrorRibbon.new(10, "Knight Companion, Queen Elizabeth", [[Colours::GOLD, 2],[Colours::SILVER, 31]], set: :order_queen_elizabeth)

RIBBONS['MC']=SolidRibbon.new(11, "Manticore Cross", Colours::BLOOD_RED)
RIBBONS['OC']=SolidRibbon.new(12, "Osterman Cross", Colours::NAVY_BLUE)

RIBBONS['KR']=MirrorRibbon.new(13, "Knight, King Roger", [[Colours::GOLD, 1],[Colours::SCARLET, 33]], set: :order_king_roger)
RIBBONS['KE']=MirrorRibbon.new(14, "Knight, Queen Elizabeth", [[Colours::GOLD, 1],[Colours::SILVER, 33]], set: :order_queen_elizabeth)
RIBBONS['CR']=MirrorRibbon.new(15, "Companion, King Roger", [[Colours::GOLD, 1],[Colours::SCARLET, 33]], set: :order_king_roger)
RIBBONS['CE']=MirrorRibbon.new(16, "Companion, Queen Elizabeth", [[Colours::GOLD, 1],[Colours::SILVER, 33]], set: :order_queen_elizabeth)

RIBBONS['SC']=MirrorRibbon.new(17, "Saganami Cross", [[Colours::WHITE, 5],[Colours::SCARLET, 25]])
RIBBONS['DGC']=MirrorRibbon.new(18, "Distinguished Gallantry Cross", [[Colours::NAVY_BLUE, 12],[Colours::PURPLE, 4],[Colours::NAVY_BLUE, 3]])

RIBBONS['OR']=SolidRibbon.new(19, "Companion, King Roger", Colours::SCARLET, set: :order_king_roger)
RIBBONS['OE']=SolidRibbon.new(20, "Companion, Queen Elizabeth", Colours::SILVER, set: :order_queen_elizabeth)

RIBBONS['OG']=HorizontalRibbon.new(21, "Order of Gallantry", [[Colours::LIGHT_BLUE, 3],[Colours::WHITE, 2]])

RIBBONS['NS']=MirrorRibbon.new(22, "Navy Star", [[Colours::NAVY_BLUE, 12],[Colours::PURPLE, 4],[Colours::WHITE, 3]])

RIBBONS['DSO']=MirrorRibbon.new(23, "Distinguished Service Order", [[Colours::NAVY_BLUE, 6],[Colours::BLOOD_RED,23]])

RIBBONS['MR']=SolidRibbon.new(24, "Member, King Roger", Colours::SCARLET, set: :order_king_roger)
RIBBONS['ME']=SolidRibbon.new(25, "Member, Queen Elizabeth", Colours::SILVER, set: :order_queen_elizabeth)

RIBBONS['MT']=nil # 26, Monarch's Thanks, not a ribbon

RIBBONS['CGM']=MirrorRibbon.new(27, "Conspicuous Gallantry Medal", [[Colours::NAVY_BLUE, 8.5],[Colours::WHITE,4],[Colours::NAVY_BLUE, 10]])

RIBBONS['GS']=MirrorRibbon.new(28, "The Gryphon Star", [[Colours::FOREST_GREEN, 9],[Colours::WHITE,5],[Colours::FOREST_GREEN, 7]])

RIBBONS['OCN']=MirrorRibbon.new(29, "Order of the Crown for Naval Service", [[Colours::NAVY_BLUE, 15.5],[Colours::BLOOD_RED,4]])

RIBBONS['WS']=nil # 30, Wound Stripe, not a ribbon

RIBBONS['QBM']=MirrorRibbon.new(31, "Queen's Bravery Medal", [[Colours::CRIMSON,2],[Colours::FOREST_GREEN,10.5],[Colours::CRIMSON,4],[Colours::WHITE,2]])

RIBBONS['SXC']=MirrorRibbon.new(32, "Sphinx Cross", [[Colours::PURPLE,10],[Colours::WHITE,3],[Colours::CRIMSON,3],[Colours::WHITE,3]])

RIBBONS['RHDSM']=MirrorRibbon.new(33, "Royal Household Distinguished Service Medal", [[Colours::SILVER,3],[Colours::GOLD,3],[Colours::ROYAL_BLUE,nil]])

RIBBONS['MiD']=nil # 34, Mentioned in Dispatches, not a ribbon

RIBBONS['RM']=MirrorRibbon.new(35, "Medal, King Roger", [[Colours::CRIMSON,(Ribbon::WIDTH-2)/2],[Colours::GOLD,2]], set: :order_king_roger)
RIBBONS['EM']=MirrorRibbon.new(36, "Medal, Queen Elizabeth", [[Colours::SILVER,(Ribbon::WIDTH-2)/2],[Colours::GOLD,2]], set: :order_queen_elizabeth)

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

RIBBONS['FEA']=MirrorRibbon.new(45, "Fleet Excellence Award", [[Colours::CRIMSON,2],[Colours::GOLD, 2],[Colours::SPACE_BLACK, nil]])
class << RIBBONS['FEA']
  def drawDevices(n, out)
    out<< "<use xlink:href=\"\#fleet_e\" class=\"device\">"
  end
end

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

RIBBONS['KR3CM']=MirrorRibbon.new(54, "King Roger III Coronation Medal", [[Colours::SILVER,2],[Colours::ROYAL_BLUE,14.5],[Colours::GOLD,2]])
RIBBONS['QE3CM']=MirrorRibbon.new(55, "Queen Elizabeth III Coronation Medal", [[Colours::SILVER,2],[Colours::ROYAL_BLUE,12.5],[Colours::CRIMSON,2],[Colours::GOLD,2]])

RIBBONS['MCAM']=MirrorRibbon.new(56, "Manticoran Combat Action Medal", [[Colours::FOREST_GREEN,6],[Colours::BLOOD_RED,nil]])

a=Colours::CRIMSON
b=Colours::ROYAL_BLUE
RIBBONS['MtSM']=MirrorRibbon.new(57, "Manticoran Service Medal", [[a,2],[Colours::GOLD,2],[a,2],[Colours::GOLD,2],[b,nil]], set: :manticoran_service)
a=Colours::ROYAL_BLUE
b=Colours::CRIMSON
RIBBONS['MRSM']=MirrorRibbon.new(58, "Manticoran Reserve Service Medal", [[a,2],[Colours::GOLD,2],[a,2],[Colours::GOLD,2],[b,nil]], set: :manticoran_service)

RIBBONS['GCM']=MirrorRibbon.new(59, "Good Conduct Medal", [[Colours::ORANGE,7.5],[Colours::CRIMSON,3],[Colours::ORANGE,nil]])

RIBBONS['SSD']=MirrorRibbon.new(60, "Space Service Deployment Ribbon", [[Colours::GOLD,4],[Colours::SPACE_BLACK,nil]])

a=Colours::ROSE
b=Colours::CHARCOAL_GREY
RIBBONS['RHE']=MirrorRibbon.new(61, "Naval Rifle High Expert Award", [[a,2],[b,6],[a,2],[b,6.5],[a,2]], set: :navy_rifle)
RIBBONS['RE']=MirrorRibbon.new(63, "Naval Rifle Expert Award", [[a,2],[b,6],[a,2],[b,nil]], set: :navy_rifle)
RIBBONS['RS']=MirrorRibbon.new(65, "Naval Rifle Sharpshooter Award", [[a,2],[b,14.5],[a,2]], set: :navy_rifle)
#RIBBONS['RM']=nil # 67, Naval Pistol Marksman Certificate, not a ribbon

RIBBONS['PHE']=MirrorRibbon.new(62, "Naval Pistol High Expert Award", [[b,8],[a,2],[b,4.5],[a,6]], set: :navy_pistol)
RIBBONS['PE']=MirrorRibbon.new(64, "Naval Pistol Expert Award", [[a,2],[b,12.5],[a,6]], set: :navy_pistol)
RIBBONS['PS']=MirrorRibbon.new(66, "Naval Pistol Sharpshooter Award", [[b,14.5],[a,6]], set: :navy_pistol)
#RIBBONS['PM']=nil # 68, Naval Rifle Marksman Certificate, not a ribbon

RIBBONS['RTR']=MirrorRibbon.new(69, "Recruit Training Ribbon", [[Colours::CRIMSON,1],[Colours::FOREST_GREEN,16],[Colours::CRIMSON,1]])

RIBBONS['NCOSCR']=MirrorRibbon.new(70, "Non-Commissioned Officers Senior Course Ribbon", [[Colours::EMERALD,3],[Colours::WHITE,2],[Colours::YELLOW,2],[Colours::WHITE,2],[Colours::EMERALD,3],[Colours::ROYAL_BLUE,nil]])

RIBBONS['AFSM']=MirrorRibbon.new(71, "Armed Forces Service Medal", [[Colours::ROYAL_BLUE,5],[Colours::WHITE,3],[Colours::CRIMSON,nil]])

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
  title+=" (&times;#{n})"if(n>1)
  out << "<svg width=\"#{Ribbon::WIDTH*Ribbon::SCALE}\" height=\"#{Ribbon::HEIGHT*Ribbon::SCALE}\" title=\"#{title}\">"
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
		</symbol>
    <symbol
       id="crown" viewbox="-18 -14.5 36 27">
      <path
         transform="scale(0.9)"
         style="stroke:none;"
         d="m 1.0902091e-4,-11.448301 c -0.86762056091,0 -1.01630842091,2.2175071 -1.01630842091,2.2175071 -0.7586735,0.5254381 -0.7750801,1.5860326 -0.7750801,1.5860326 -0.7812993,0 -1.8114815,0.7520347 -1.9260834,2.3411124 -3.42903,-0.9804422 -7.9425781,-3.2141713 -9.7871361,0.1015751 -2.216876,3.9850285 1.142653,7.9107951 3.9611392,10.7326391 l 0,1.0071785 0.5644771,0 0,3.5306382 17.9579771,0 0,-3.5306382 0.5644772,0 0,-1.0071785 C 12.362058,2.7087213 15.721587,-1.2170453 13.504711,-5.2020738 11.660153,-8.5178202 7.146611,-6.2840911 3.717581,-5.3036489 3.6029791,-6.8927266 2.5727968,-7.6447613 1.7914976,-7.6447613 c 0,0 -0.016425,-1.0605945 -0.7750864,-1.5860326 0,0 -0.14868161,-2.2175071 -1.01630217909,-2.2175071 z"/>
      <g
         style="fill:none;"
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
    </symbol>
    <symbol id="fleet_e" viewbox="-13.5 -13.5 27 27">
    <path
       style="fill:url(#linearGradient27741);stroke:url(#linearGradient27814);stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;"
       d="m 0.00847179,6.8280633 6.42000001,0 c 0.76,0 1.37,-0.04 1.83,-0.12 0.48,-0.1 0.89,-0.21 1.23,-0.33 l 0.12,0 0.12,-0.06 -0.66,3.6899997 -1.59,0 -15.36,0 -0.03,0 0,0 c 0.02,-0.02 0.03,-0.04 0.03,-0.06 0.18,-0.36 0.32,-0.76 0.42,-1.2 0.1,-0.46 0.15,-1.14 0.15,-2.04 l 0,-12.66 c 0,-0.9 -0.05,-1.57 -0.15,-2.01 -0.1,-0.46 -0.24,-0.87 -0.42,-1.23 -0.023685,-0.027075 -0.016444,-0.032889 -0.03,-0.06 l 1.29,0 15.36,0 0.03,0 0.6,3.69 c -0.04,-0.02 -0.08,-0.03 -0.12,-0.03 -0.04,-0.02 -0.08,-0.03 -0.12,-0.03 -0.36,-0.12 -0.78,-0.22 -1.26,-0.3 -0.46,-0.1 -1.09,-0.15 -1.89,-0.15 l -5.97000001,0 0,4.56 5.22000001,0 c 0.78,0 1.4,-0.04 1.86,-0.12 0.48,-0.1 0.9,-0.21 1.26,-0.33 l 0.12,0 0.12,-0.06 0,4.2 c -0.04,-0.02 -0.08,-0.03 -0.12,-0.03 -0.04,-0.02 -0.08,-0.03 -0.12,-0.03 -0.36,-0.12 -0.78,-0.22 -1.26,-0.3 -0.46,-0.1 -1.08,-0.15 -1.86,-0.15 l -5.22000001,0 0,5.16 z"/></symbol>
    <linearGradient
       id="shinyBase">
      <stop
         style="stop-color:#808080;stop-opacity:1"
         offset="0" />
      <stop
         offset="0.51118267"
         style="stop-color:#e6e6e6;stop-opacity:1" />
      <stop
         style="stop-color:#666666;stop-opacity:1"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#shinyBase"
       id="linearGradient27741"
       gradientUnits="userSpaceOnUse"
       gradientTransform="translate(-0.5,-3.25)"
       spreadMethod="pad"
       x1="-13.9375"
       y1="-10.512797"
       x2="15.8125"
       y2="17.299704" />
    <linearGradient
       xlink:href="#shinyBase"
       id="linearGradient27814"
       x1="6.1938648"
       y1="-7.5594373"
       x2="-3.3539"
       y2="6.3155632"
       gradientUnits="userSpaceOnUse" />

    <symbol
       id="star_laurel"
       viewbox="-18 -13.5 36 27">
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


abbrs=['KR3CM','SSD','AFSM','NCD', 'MT','HOSM','SAPC','PE','RE','RTR','NAM','HOSM','SAPC','MCAM','MCAM','KCE','MT','MCAM']


def board(entries, out, defs)
  width = entries.size >= 12 ? 4 : 3
  first_width = entries.size % width
  first_row = entries.shift(first_width)
  
  rows=[first_row]+entries.each_slice(width).to_a
  out<< "<div class=\"ribbon-board\">"
  rows.each do |row|
    out<< "<div>"
    row.each do |entry|
      ribbon_out(entry.ribbon, entry.count, out, defs)
      defs=false
    end
    out<< "</div>"
  end
  out<< "</div>"
  
end
records = [
  ["Lieutenant-Commander", "Sir Mark Gledhill, KCE",['KR3CM','SSD','AFSM','NCD', 'MT','HOSM','SAPC','PE','RE','RTR','NAM','HOSM','SAPC','MCAM','MCAM','KCE','MT']],
  ["Lieutenant (SG)", "Robert Allen Day", ['KR3CM','SSD','AFSM']],
  ["Chief Petty Officer", "Kyle Polkinghorne", ['SSD','MD','HOSM','SAPC']],
  ["Disbursing Clerk First Class", "Thomas Demkiw", ['SSD']],
  ["Spacer First Class", "Rowan Wilson", ['SSD','AFSM']],
  ["Data Systems Technician Second Class", "Kevin Michael Smith", ['SSD','AFSM', 'MCAM']],
  ["Spacer Third Class", "Avi Woodward-Kelen", []],
  ["Spacer Third Class", "Robert Bligh", ['SSD']],
  ["Spacer Third Class", "John Barazzuol", []],
  ["Examplar-General", "Dame Alice Foo, PMV, GCE, OM, OG", ['KR3CM','SSD','AFSM','NCD', 'MT','SAPC','PE','RE','RTR','NAM','SAPC','MCAM','MCAM','GCE','MT','KDE', 'PMV', 'MCAM', 'FEA', 'POW','POW','POW','POW', 'OM', 'RM', 'MC', 'OG','OG','OG','OG','OG']+['HOSM']*15],
]
puts <<EOS
<!DOCTYPE html>
<html>
  <head>
    <title></title>
    <style type="text/css">
      .ribbon-board {width:423px}
      .ribbon-board>div {text-align: center; line-height:0;}
      .ribbon-board>div+div {margin-top:1px;}
      .ribbon-board>div>svg+svg {padding-left:1px;}
      #star, #star_laurel {fill: #a05a2c; /*stroke: #502d16;*/ stroke-width: 0.5px;}
      #laurels {fill: #a05a2c; /*stroke: #502d16;*/ stroke-width: 0.5px;}
      #crown {fill: #aaaaaa; stroke: #555555; stroke-width: 0.5px;}
      .device {filter:url("#shadow")}
    </style>
  </head>
  <body style="background-color: black; color: yellow">
EOS

puts "<dl>"
defs=true
records.each do |rank, name, abbrs|
  puts "<dt>#{rank} #{name}</dt>"
  puts "<dl>"
  board(ribbon_collapse(abbrs), $stdout, defs)
  defs=false
  puts "</dl>"
end
puts "</dl>"

puts "<table>"
RIBBONS.each_pair.select{|key, ribbon| not ribbon.nil?}.to_a.sort{|p1, p2| p1[1].order <=> p2[1].order}.each do |key, ribbon|
  puts "<tr>"
  
  puts "<th scope=\"row\">#{ribbon.order}</th>"
  puts "<td>#{key}</td>"
  puts "<td>"
  ribbon_out(ribbon, 1, $stdout, defs)
  puts "</td>"
  puts "<td>#{ribbon.name}</td>"
  puts "</tr>"
end
puts "</table>"

puts <<EOS
  </body>
</html>
EOS
