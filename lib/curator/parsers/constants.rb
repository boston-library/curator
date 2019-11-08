# frozen_string_literal: true

module Curator
  module Parsers
    # move useful static data structures from Bplmodels::Constants here
    class Constants
      # from MARC Appendix F - Initial Definite and Indefinite Articles
      # see http://www.loc.gov/marc/bibliographic/bdapndxf.html
      # BUT we are excluding:
      # ['am', 'as', 'an t-', 'ang mga', 'bat', 'hen', 'in', 'it', 'na h-',
      #  'o', 'to', 'ton', 'us']
      # since these are tougher to deal with (or non-English specific),
      # and unlikely to be used
      NONSORT_ARTICLES = %w(
        a a' al al- an ane ang az bir d' da das de dei dem den der des det di
        die dos e 'e een eene egy ei ein eine einem einen einer eines eit el el-
        els en enne et ett eyn eyne gl' gli ha- hai he hē he- heis hena henas het
        hin hina hinar hinir hinn hinna hinnar hinni hins hinu hinum hið ho hoi i
        ih' il il- ka ke l' l- la las le les lh lhi li lis lo los lou lu mga mia
        'n na njē ny 'o os 'r 's 't ta tais tas tē tēn tēs the tō tois tōn tou um
        uma un un' una une unei unha uno uns unui y ye yr
      ).freeze
    end
  end
end
