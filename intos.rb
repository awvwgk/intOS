#!/bin/ruby

class Hash
  def + (other)
    self.merge(other){|k,i,j|i+j}
  end
  def - (other)
    self.merge(other){|k,i,j|i-j}
  end
  def parse(string)
    (0...(string.length)).each do |i|
      case string[i]
      when 'x'
        self['1'] += 1
      when 'y'
        self['2'] += 1
      when 'z'
        self['3'] += 1
      end
    end
    self
  end
  def sum
    sum = 0
    self.each do |k,v| sum += v end
    sum
  end
  def to_out j
    s = []
    self.each do |k,i|
      if i==1
        s << "rp%s(%s)" % [j,k.to_s]
      else
        s << "rp%s(%s)**%i" % [j,k.to_s,i]
      end unless i==0
    end
    s
  end
  def pair
    t = {}
    self.each do |k,i|
      t[k] = i.pair
    end
    t
  end
end
class Integer
  def pair
    self * (self-1) / 2
  end
end
def singles(a,b)
  dum={'1'=>0,'2'=>0,'3'=>0}
  f  = [] 
  ap = a.pair
  bp = b.pair
  pp = (a+b).pair
  ip = pp - ap - bp
  ap.each { |k,v| if v>0 then f << [dum+{k=>2},dum,v] end }
  bp.each { |k,v| if v>0 then f << [dum,dum+{k=>2},v] end }
  ip.each { |k,v| if v>0 then f << [dum+{k=>1},dum+{k=>1},v] end }
  f
end
def result(a,b)
  f = []
  t = (a.to_out('i')+b.to_out('j'))
  f << t.join(' * ') unless t.empty?
  s = singles a,b
  s.each do |k|
    ac = a.clone - k[0]
    dc = b.clone - k[1]
    if k[2]==1 then t = ["aij"] else t = ["%s*aij" % k[2]] end
    _ = result(ac,dc)
    t << _ unless _.empty?
    f << t
  end
  f
end
class Array
  def printout
    d = "\n     ++ "
    self.each do |e|
      if Array.try_convert e
        _ = e.shift
        unless e.empty?
          printf d+_+' * ( '
          e.each do |i| i.printout end
          printf ' )'
        else
          printf d+_
        end
      else
        printf e
      end
    end
  end
end

# get gaussian on atom 1
a = {'1'=>0,'2'=>0,'3'=>0}.parse ARGV[0]
# get gaussian on atom 2
b = {'1'=>0,'2'=>0,'3'=>0}.parse ARGV[1]
# get full OS recurrsion
f = result a,b
# print to STDOUT
o = 'spdfgh'
puts <<EOF
C INT #{'- '*30+`date +%y%m%d`.chomp}
      pure function #{o[a.sum]+o[b.sum]}_ovlp#{' '*28}(sij,aij,rpi,rpj)
     .     result(ovlp)
      real*8, intent(in)  :: sij
      real*8, intent(in)  :: aij
      real*8, intent(in)  :: rpi(3)
      real*8, intent(in)  :: rpj(3)
      real*8  :: ovlp

EOF
printf "      ovlp = sij * ( "
f.printout
puts " )"
puts <<EOF

      return
      end function #{o[a.sum]+o[b.sum]}_ovlp
EOF
