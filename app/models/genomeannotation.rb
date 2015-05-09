class Genomeannotation < ActiveRecord::Base
  #acts_as_copy_target

  validates :name, presence: true, length: {minimum: 3}
  validates :chr, presence: true, inclusion: {in: %w(Chrom pSol1)}
  validates :author, presence: true, length: {minimum: 7}
  validates :feature, presence: true, inclusion: {in: %w(TSS RBS Promoter Hairpin ORF Transcript Factor)}
  validates :start_site, presence: true, numericality: {only_integer: true}
  validates :stop_site, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: :start_site}
  validates :strand, presence: true, inclusion: {in: ["+","-"]}
  validates :technique, presence: true, length: {minimum: 5}
  validate :extravalidation
  def self.search(coordinates)
    c,s,e=coordinates
    #self.where('((start_site >= ? AND start_site <= ?) OR (stop_site >= ? AND stop_site <= ?)) AND chr = ?',s.to_i,e.to_i,s.to_i,e.to_i,c).select("name,start_site,stop_site,feature,strand")
    self.where("("+self.where(start_site: (s.to_i..e.to_i), stop_site: (s.to_i..e.to_i)).where_values.map(&:to_sql).join(" OR ")+") AND chr = ?",c)
  end

  def extravalidation
    test = (extra.blank? || extra.include?(" "))
    errors.add(:extra,"must be formated as gtf 'attribute1 value1; attribute2 value2; ...'") unless test
    test
  end
end


