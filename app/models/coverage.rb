class Coverage < ActiveRecord::Base
  acts_as_copy_target
  validates :chr, presence: true, inclusion: {in: %w(Chrom pSol1)}
  validates :base, presence: true, numericality: {only_integer: true}
  validates :stress, presence: true, inclusion: {in: %w(NS BuOH BA)}
  validates :time, presence: true, inclusion: {in: %w(15 75 150 270)}
  validates :rep, presence: true, inclusion: {in: %w(A B)}
  validates :strand, presence: true, inclusion: {in: %w(+ -)}
  validates :cov, presence: true, numericality: {only_integer: true}
  validates :tex, presence: true, inclusion: {in: [1,0]}

  def self.search(coordinates,condition,x)
    c,s,e=coordinates
    c,s,e,=ActiveRecord::Base.sanitize(c).gsub(/'/,''),ActiveRecord::Base.sanitize(s.to_i),ActiveRecord::Base.sanitize(e.to_i)
    stress,time,tex=condition
    stress=ActiveRecord::Base.sanitize(stress).gsub(/'/,'') if stress
    time=ActiveRecord::Base.sanitize(time).gsub(/'/,'') if time
    tex=ActiveRecord::Base.sanitize(tex).gsub(/'/,'') if tex

    query = "select base, strand, cov from coverages where base >= ? AND base <= ? AND chr = ?"
    parameters = [s,e,c]
    (query << " AND stress = ?"; parameters << stress) if stress
    (query << " AND time = ?"; parameters << time) if time
    (query << " AND tex = ?"; parameters << tex) if tex
    
    query=ActiveRecord::Base.send(:sanitize_sql_array, [query, *parameters])
    results=[]
    ActiveRecord::Base.connection.execute(query).each_hash {|x| results << x}

=begin
# PostgreSQL legacy code
    query="select base, strand, cov from coverages where base >= $1 AND base <= $2 AND chr = $3"
    variables="s,e,c"
    x=4
    (query+=" AND stress = $#{x}"; x+=1; variables+=",stress") if stress
    (query+=" AND time = $#{x}"; x+=1; variables+=",time") if time
    (query+=" AND tex = $#{x}"; x+=1; variables+=",tex") if tex
    queryname="query_#{Time.now}_#{stress}_#{time}_#{tex}_#{x}"

    conn=ActiveRecord::Base.connection.raw_connection
    conn.prepare(queryname,query)
    execute="conn.exec_prepared(queryname,[#{variables}])"
    eval(execute)
=end
    results
  end
end
