# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BedAnno.t'

our $data;
our $extradb;

BEGIN {
    unless ( grep /blib/, @INC ) {
        chdir 't' if -d 't';
	unshift @INC, '../plugins' if -d '../plugins';
        unshift @INC, '../lib' if -d '../lib';
        $data = '../data';
	$extradb = '../db';
    }
}
$data ||= "data";
$extradb ||= "db";
my %opts = (
    db     => "$data/test.bed.gz",
    tr     => "$data/test.fas.gz",
    batch  => 1,
);

if ( -e $extradb and -r $extradb ) {
    if ( -e "$extradb/cytoBand/cytoBand_hg19_grch37.txt.gz" ) {
	$opts{cytoBand} = "$extradb/cytoBand/cytoBand_hg19_grch37.txt.gz";
    }
    if ( -e "$extradb/dbsnp/snp137.bed.gz" ) {
	$opts{dbSNP} = "$extradb/dbsnp/snp137.bed.gz";
    }
    if ( -e "$extradb/tgp/tgp_phaseI_version3_hg19.dbdump.bed.gz" ) {
	$opts{tgp} = "$extradb/tgp/tgp_phaseI_version3_hg19.dbdump.bed.gz";
    }
    if ( -e "$extradb/CG/CG54_20130709_stats_filtered_ct0.tsv.gz" ) {
	$opts{cg54} = "$extradb/CG/CG54_20130709_stats_filtered_ct0.tsv.gz";
    }
    if ( -e "$extradb/NHLBI/ESP6500SI-V2-SSA137.NHLBI.bed.rmanchor.uniq.gz" ) {
	$opts{esp6500} = "$extradb/NHLBI/ESP6500SI-V2-SSA137.NHLBI.bed.rmanchor.uniq.gz";
    }
    if ( -e "$extradb/pfam/Pfam-A-ncbi_2012-12-21.bed.gz" ) {
	$opts{pfam} = "$extradb/pfam/Pfam-A-ncbi_2012-12-21.bed.gz";
    }
    if ( -e "$extradb/predictions/predictDB_for_anno104.tab.gz" ) {
	$opts{prediction} = "$extradb/predictions/predictDB_for_anno104.tab.gz";
    }
    # phyloP and wellderly need extra test
}

use Test::Most;
BEGIN { use_ok('BedAnno') }

test_tabix("$data/test_db.bed.gz");
my $beda = BedAnno->new( %opts );

#explain "The database are:", $beda;
# ncRNA part
my $crawler_input = {
    chr => 1,
    start => 14409,
    end => 14410,
    ref => 'c',
    alt => 'a',
};

my $snv_parse = bless(
    {
        'alt'    => 'A',
        'altlen' => 1,
        'chr'    => '1',
        'end'    => 14410,
        'guess'  => 'snv',
        'imp'    => 'snv',
        'pos'    => 14409,
        'ref'    => 'C',
        'reflen' => 1,
        'sm'     => 1
    },
    'BedAnno::Var'
);

my $crawler_input2 = {
    chr => 1,
    start => 14410,
    ref => "C",
    alt => "CGAATAGCTA",
};

my $insert_parse = bless(
    {
        'alt'    => 'GAATAGCTA',
        'altlen' => 9,
        'chr'    => '1',
        'end'    => 14410,
        'guess'  => 'ins',
        'imp'    => 'ins',
        'pos'    => 14410,
        'ref'    => '',
        'reflen' => 0,
        'sm'     => 0
    },
    'BedAnno::Var'
);

my $del_parse = bless(
    {
        'alt'    => '',
        'altlen' => 0,
        'chr'    => '1',
        'end'    => 14417,
        'guess'  => 'del',
        'imp'    => 'del',
        'pos'    => 14410,
        'ref'    => 'TAGATCG',
        'reflen' => 7,
        'sm'     => 2
    },
    'BedAnno::Var'
);

my $delins_parse = bless(
    {
        'alt'    => 'GT',
        'altlen' => 2,
        'chr'    => '1',
        'end'    => 14414,
        'guess'  => 'delins',
        'imp'    => 'delins',
        'pos'    => 14409,
        'ref'    => 'CTAGA',
        'reflen' => 5,
        'sm'     => 2
    },
    'BedAnno::Var'
);

my $rep_parse = bless(
    {
        '+' => {
            'ba'  => 'TAGTAGTAG',
            'bal' => 9,
            'bp'  => 14413,
            'br'  => '',
            'brl' => 0
        },
        '-' => {
            'ba'  => 'TAGTAGTAG',
            'bal' => 9,
            'bp'  => 14410,
            'br'  => '',
            'brl' => 0
        },
        'a'      => 'TAGTAGTAGTAG',
        'al'     => 12,
        'alt'    => 'TAGTAGTAGTAGA',
        'alt_cn' => 4,
        'altlen' => 13,
        'chr'    => '1',
        'end'    => 14414,
        'guess'  => 'delins',
        'imp'    => 'rep',
        'p'      => 14410,
        'pos'    => 14410,
        'r'      => 'TAG',
        'ref'    => 'TAGA',
        'ref_cn' => 1,
        'reflen' => 4,
        'rep'    => 'TAG',
        'replen' => 3,
        'rl'     => 3,
        'sm'     => 2
    },
    'BedAnno::Var'
);

my $subs_parse = bless(
    {
        'alt'      => 'TGTGT',
        'altlen'   => 5,
        'chr'      => '1',
        'end'      => 14414,
        'guess'    => 'delins',
        'imp'      => 'delins',
        'pos'      => 14409,
        'ref'      => 'CATGA',
        'reflen'   => 5,
        'sep_snvs' => [ 14410, 14411, 14414 ],
        'sm'       => 3
    },
    'BedAnno::Var'
);

my $no_call_parse = bless(
    {
        'alt'    => '?',
        'chr'    => '1',
        'end'    => 14410,
        'guess'  => 'no-call',
        'imp'    => 'ins',
        'pos'    => 14410,
        'ref'    => '',
        'reflen' => 0,
        'sm'     => 0
    },
    'BedAnno::Var'
);

my $snv_varanno = bless(
    {
        'trInfo' => {
            'NR_024540.1' => {
                'c'             => 'n.1721G>T',
                'cdsBegin'      => '',
                'cdsEnd'        => '',
                'ei_Begin'      => 'EX11E',
                'ei_End'        => 'EX11E',
                'exin'          => 'EX11E',
                'exonIndex'     => '11',
                'func'          => 'ncRNA',
                'funcSO'        => '',
                'funcSOname'    => 'unknown',
                'geneId'        => '653635',
                'geneSym'       => 'WASH7P',
                'genepart'      => 'ncRNA',
                'genepartIndex' => '11',
                'genepartSO'    => 'SO:0000655',
                'intronIndex'   => '.',
                'prot'          => '',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'R11E',
                'r_Begin'       => 'R11E',
                'r_End'         => 'R11E',
                'rnaBegin'      => 1721,
                'rnaEnd'        => 1721,
                'strd'          => '-',
                'trAlt'         => 'T',
                'trRef'         => 'G',
                'trRefComp'     => {
                    'EX11E' => 1
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'A',
                'altlen'    => 1,
                'chr'       => '1',
                'end'       => 14410,
                'gHGVS'     => 'g.14409C>A',
                'guess'     => 'snv',
                'imp'       => 'snv',
                'pos'       => 14409,
                'ref'       => 'C',
                'refbuild'  => 'GRCh37',
                'reflen'    => 1,
                'sm'        => 1,
                'varTypeSO' => 'SO:0001483'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);

my $ins_varanno = bless(
    {
        'trInfo' => {
            'NR_024540.1' => {
                'c'             => 'n.1720_1721insTAGCTATTC',
                'cdsBegin'      => '',
                'cdsEnd'        => '',
                'ei_Begin'      => 'EX11E',
                'ei_End'        => 'EX11E',
                'exin'          => 'EX11E',
                'exonIndex'     => '11',
                'func'          => 'ncRNA',
                'funcSO'        => '',
                'funcSOname'    => 'unknown',
                'geneId'        => '653635',
                'geneSym'       => 'WASH7P',
                'genepart'      => 'ncRNA',
                'genepartIndex' => '11',
                'genepartSO'    => 'SO:0000655',
                'intronIndex'   => '.',
                'prot'          => '',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'R11E',
                'r_Begin'       => 'R11E',
                'r_End'         => 'R11E',
                'rnaBegin'      => 1721,
                'rnaEnd'        => 1720,
                'strd'          => '-',
                'trAlt'         => 'TAGCTATTC',
                'trRef'         => '',
                'trRefComp'     => {
                    'EX11E' => 0
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'GAATAGCTA',
                'altlen'    => 9,
                'chr'       => '1',
                'end'       => 14410,
                'gHGVS'     => 'g.14410_14411insGAATAGCTA',
                'guess'     => 'ins',
                'imp'       => 'ins',
                'pos'       => 14410,
                'ref'       => '',
                'refbuild'  => 'GRCh37',
                'reflen'    => 0,
                'sm'        => 0,
                'varTypeSO' => 'SO:0000667'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);

my $del_varanno = bless(
    {
        'trInfo' => {
            'NR_024540.1' => {
                'c'             => 'n.1714_1720del',
                'cdsBegin'      => '',
                'cdsEnd'        => '',
                'ei_Begin'      => 'EX11E',
                'ei_End'        => 'EX11E',
                'exin'          => 'EX11E',
                'exonIndex'     => '11',
                'func'          => 'ncRNA',
                'funcSO'        => '',
                'funcSOname'    => 'unknown',
                'geneId'        => '653635',
                'geneSym'       => 'WASH7P',
                'genepart'      => 'ncRNA',
                'genepartIndex' => '11',
                'genepartSO'    => 'SO:0000655',
                'intronIndex'   => '.',
                'prot'          => '',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'R11E',
                'r_Begin'       => 'R11E',
                'r_End'         => 'R11E',
                'rnaBegin'      => 1714,
                'rnaEnd'        => 1720,
                'strd'          => '-',
                'trAlt'         => '',
                'trRef'         => 'GAACTGA',
                'trRefComp'     => {
                    'EX11E' => 7
                }
            }
        },
        'var' => bless(
            {
                'alt'       => '',
                'altlen'    => 0,
                'chr'       => '1',
                'end'       => 14417,
                'gHGVS'     => 'g.14411_14417delTAGATCG',
                'guess'     => 'del',
                'imp'       => 'del',
                'pos'       => 14410,
                'ref'       => 'TAGATCG',
                'refbuild'  => 'GRCh37',
                'reflen'    => 7,
                'sm'        => 2,
                'varTypeSO' => 'SO:0000159'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);

my $rep_varanno = bless(
    {
        'trInfo' => {
            'NR_024540.1' => {
                'c'             => 'n.1718_1719delinsCTACTACTACT',
                'cdsBegin'      => '',
                'cdsEnd'        => '',
                'ei_Begin'      => 'EX11E',
                'ei_End'        => 'EX11E',
                'exin'          => 'EX11E',
                'exonIndex'     => '11',
                'func'          => 'ncRNA',
                'funcSO'        => '',
                'funcSOname'    => 'unknown',
                'geneId'        => '653635',
                'geneSym'       => 'WASH7P',
                'genepart'      => 'ncRNA',
                'genepartIndex' => '11',
                'genepartSO'    => 'SO:0000655',
                'intronIndex'   => '.',
                'prot'          => '',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'R11E',
                'r_Begin'       => 'R11E',
                'r_End'         => 'R11E',
                'rnaBegin'      => 1718,
                'rnaEnd'        => 1720,
                'strd'          => '-',
                'trAlt'         => 'CTACTACTACTA',
                'trRef'         => 'TGA',
                'trRefComp'     => {
                    'EX11E' => 3
                }
            }
        },
        'var' => bless(
            {
                '+' => {
                    'ba'  => 'TAGTAGTAG',
                    'bal' => 9,
                    'bp'  => 14413,
                    'br'  => '',
                    'brl' => 0
                },
                '-' => {
                    'ba'  => 'TAGTAGTAG',
                    'bal' => 9,
                    'bp'  => 14410,
                    'br'  => '',
                    'brl' => 0
                },
                'a'         => 'TAGTAGTAGTAG',
                'al'        => 12,
                'alt'       => 'TAGTAGTAGTAGA',
                'alt_cn'    => 4,
                'altlen'    => 13,
                'chr'       => '1',
                'end'       => 14414,
                'gHGVS'     => 'g.14411TAG[1>4]',
                'guess'     => 'delins',
                'imp'       => 'rep',
                'p'         => 14410,
                'pos'       => 14410,
                'r'         => 'TAG',
                'ref'       => 'TAGA',
                'ref_cn'    => 1,
                'refbuild'  => 'GRCh37',
                'reflen'    => 4,
                'rep'       => 'TAG',
                'replen'    => 3,
                'rl'        => 3,
                'sm'        => 2,
                'varTypeSO' => 'SO:1000032'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);

my $delins_varanno = bless(
    {
        'trInfo' => {
            'NR_024540.1' => {
                'c'             => 'n.1717_1721delinsAC',
                'cdsBegin'      => '',
                'cdsEnd'        => '',
                'ei_Begin'      => 'EX11E',
                'ei_End'        => 'EX11E',
                'exin'          => 'EX11E',
                'exonIndex'     => '11',
                'func'          => 'ncRNA',
                'funcSO'        => '',
                'funcSOname'    => 'unknown',
                'geneId'        => '653635',
                'geneSym'       => 'WASH7P',
                'genepart'      => 'ncRNA',
                'genepartIndex' => '11',
                'genepartSO'    => 'SO:0000655',
                'intronIndex'   => '.',
                'prot'          => '',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'R11E',
                'r_Begin'       => 'R11E',
                'r_End'         => 'R11E',
                'rnaBegin'      => 1717,
                'rnaEnd'        => 1721,
                'strd'          => '-',
                'trAlt'         => 'AC',
                'trRef'         => 'CTGAG',
                'trRefComp'     => {
                    'EX11E' => 5
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'GT',
                'altlen'    => 2,
                'chr'       => '1',
                'end'       => 14414,
                'gHGVS'     => 'g.14410_14414delCTAGAinsGT',
                'guess'     => 'delins',
                'imp'       => 'delins',
                'pos'       => 14409,
                'ref'       => 'CTAGA',
                'refbuild'  => 'GRCh37',
                'reflen'    => 5,
                'sm'        => 2,
                'varTypeSO' => 'SO:1000032'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);

my $subs_varanno = bless(
    {
        'trInfo' => {
            'NR_024540.1' => {
                'c'             => 'n.1717_1721delinsACACA',
                'cdsBegin'      => '',
                'cdsEnd'        => '',
                'ei_Begin'      => 'EX11E',
                'ei_End'        => 'EX11E',
                'exin'          => 'EX11E',
                'exonIndex'     => '11',
                'func'          => 'ncRNA',
                'funcSO'        => '',
                'funcSOname'    => 'unknown',
                'geneId'        => '653635',
                'geneSym'       => 'WASH7P',
                'genepart'      => 'ncRNA',
                'genepartIndex' => '11',
                'genepartSO'    => 'SO:0000655',
                'intronIndex'   => '.',
                'prot'          => '',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'R11E',
                'r_Begin'       => 'R11E',
                'r_End'         => 'R11E',
                'rnaBegin'      => 1717,
                'rnaEnd'        => 1721,
                'strd'          => '-',
                'trAlt'         => 'ACACA',
                'trRef'         => 'CTGAG',
                'trRefComp'     => {
                    'EX11E' => 5
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'TGTGT',
                'altlen'    => 5,
                'chr'       => '1',
                'end'       => 14414,
                'gHGVS'     => 'g.14410_14414delCATGAinsTGTGT',
                'guess'     => 'delins',
                'imp'       => 'delins',
                'pos'       => 14409,
                'ref'       => 'CATGA',
                'refbuild'  => 'GRCh37',
                'reflen'    => 5,
                'sep_snvs'  => [ 14410, 14411, 14414 ],
                'sm'        => 3,
                'varTypeSO' => 'SO:1000032'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);

my $no_call_varanno = bless(
    {
        'trInfo' => {
            'NR_024540.1' => {
                'c'             => 'n.1720_1721ins?',
                'cdsBegin'      => '',
                'cdsEnd'        => '',
                'ei_Begin'      => 'EX11E',
                'ei_End'        => 'EX11E',
                'exin'          => 'EX11E',
                'exonIndex'     => '11',
                'func'          => 'unknown-no-call',
                'funcSO'        => '',
                'funcSOname'    => 'unknown-no-call',
                'geneId'        => '653635',
                'geneSym'       => 'WASH7P',
                'genepart'      => 'ncRNA',
                'genepartIndex' => '11',
                'genepartSO'    => 'SO:0000655',
                'intronIndex'   => '.',
                'prot'          => '',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'R11E',
                'r_Begin'       => 'R11E',
                'r_End'         => 'R11E',
                'rnaBegin'      => 1721,
                'rnaEnd'        => 1720,
                'strd'          => '-',
                'trAlt'         => '?',
                'trRef'         => '',
                'trRefComp'     => {
                    'EX11E' => 0
                }
            }
        },
        'var' => bless(
            {
                'alt'       => '?',
                'chr'       => '1',
                'end'       => 14410,
                'gHGVS'     => 'g.14410_14411ins?',
                'guess'     => 'no-call',
                'imp'       => 'ins',
                'pos'       => 14410,
                'ref'       => '',
                'refbuild'  => 'GRCh37',
                'reflen'    => 0,
                'sm'        => 0,
                'varTypeSO' => 'no-call'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);

test_parse_var( $snv_parse,     $crawler_input );
test_parse_var( $snv_parse,     "chr1", 14410, "C",        "A" );
test_parse_var( $insert_parse,  $crawler_input2 );
test_parse_var( $insert_parse,  "chr1", 14410, "C",        "CGAATAGCTA" );
test_parse_var( $del_parse,     "chr1", 14410, "CTAGATCG", "C" );
test_parse_var( $rep_parse,     "chr1", 14410, "CTAGA",    "CTAGTAGTAGTAGA" );
test_parse_var( $delins_parse,  "chr1", 14410, "CTAGA",    "GT" );
test_parse_var( $subs_parse,    "chr1", 14410, "CATGA",    "TGTGT" );
test_parse_var( $no_call_parse, "chr1", 14410, 14410,      "", '?' );

test_varanno( $snv_varanno, $snv_parse );
test_varanno( $ins_varanno, $insert_parse );
test_varanno( $del_varanno, $del_parse );
test_varanno( $rep_varanno, $rep_parse );
test_varanno( $delins_varanno, $delins_parse );
test_varanno( $subs_varanno, $subs_parse );
test_varanno( $no_call_varanno, $no_call_parse );

# =================== END of ncRNA test ====================
#
# For coding RNA test
my $cds_rna_delins = bless(
    {
        'alt'    => 'A',
        'altlen' => 1,
        'chr'    => '8',
        'end'    => 24811066,
        'guess'  => 'snv',
        'imp'    => 'snv',
        'pos'    => 24811065,
        'ref'    => 'G',
        'reflen' => 1,
        'sm'     => 1
    },
    'BedAnno::Var'
);
my $cds_no_change = bless(
    {
        'alt'    => '',
        'altlen' => 0,
        'chr'    => '8',
        'end'    => 24811065,
        'guess'  => 'del',
        'imp'    => 'del',
        'pos'    => 24811064,
        'ref'    => 'G',
        'reflen' => 1,
        'sm'     => 1
    },
    'BedAnno::Var'
);
my $cds_snv = bless(
    {
        'alt'    => 'T',
        'altlen' => 1,
        'chr'    => '8',
        'end'    => 24811067,
        'guess'  => 'snv',
        'imp'    => 'snv',
        'pos'    => 24811066,
        'ref'    => 'G',
        'reflen' => 1,
        'sm'     => 1
    },
    'BedAnno::Var'
);
my $cds_del = bless(
    {
        'alt'    => '',
        'altlen' => 0,
        'chr'    => '8',
        'end'    => 24811067,
        'guess'  => 'del',
        'imp'    => 'del',
        'pos'    => 24811066,
        'ref'    => 'G',
        'reflen' => 1,
        'sm'     => 1
    },
    'BedAnno::Var'
);
my $cds_ins = bless(
    {
        'alt'    => 'GGG',
        'altlen' => 3,
        'chr'    => '8',
        'end'    => 24811067,
        'guess'  => 'ins',
        'imp'    => 'ins',
        'pos'    => 24811067,
        'ref'    => '',
        'reflen' => 0,
        'sm'     => 0
    },
    'BedAnno::Var'
);
my $cds_rep = bless(
    {
        '+' => {
            'ba'  => '',
            'bal' => 0,
            'bp'  => 49395685,
            'br'  => 'GCCGCC',
            'brl' => 6
        },
        '-' => {
            'ba'  => '',
            'bal' => 0,
            'bp'  => 49395673,
            'br'  => 'GCCGCC',
            'brl' => 6
        },
        'a'      => 'GCCGCCGCCGCC',
        'al'     => 12,
        'alt'    => 'GCCGCCGCCGCC',
        'alt_cn' => 4,
        'altlen' => 12,
        'chr'    => '3',
        'end'    => 49395691,
        'guess'  => 'delins',
        'imp'    => 'rep',
        'p'      => 49395673,
        'pos'    => 49395673,
        'r'      => 'GCCGCCGCCGCCGCCGCC',
        'ref'    => 'GCCGCCGCCGCCGCCGCC',
        'ref_cn' => 6,
        'reflen' => 18,
        'rep'    => 'GCC',
        'replen' => 3,
        'rl'     => 18,
        'sm'     => 2
    },
    'BedAnno::Var'
);
my $cds_delins = bless(
    {
        'alt'      => 'TC',
        'altlen'   => 2,
        'chr'      => '1',
        'end'      => 865534,
        'guess'    => 'delins',
        'imp'      => 'delins',
        'pos'      => 865532,
        'ref'      => 'AG',
        'reflen'   => 2,
        'sep_snvs' => [ 865533, 865534 ],
        'sm'       => 3
    },
    'BedAnno::Var'
);
my $cds_no_call = bless(
    {
        'alt'    => 'N',
        'altlen' => 1,
        'chr'    => '1',
        'end'    => 861320,
        'guess'  => 'no-call',
        'imp'    => 'snv',
        'pos'    => 861319,
        'ref'    => 'T',
        'reflen' => 1,
        'sm'     => 1
    },
    'BedAnno::Var'
);

test_parse_var( $cds_rna_delins, 'chr8', 24811065, 24811066, "G", "A" );  # del-ins?
test_parse_var( $cds_no_change, 'chr8', 24811064, 24811065, "G", "" ); # no-change?
test_parse_var( $cds_snv, 'chr8', 24811066, 24811067, "G", "T" );
test_parse_var( $cds_del, 'chr8', 24811066, 24811067, "G", "" );
test_parse_var( $cds_ins, 'chr8', 24811067, 24811067, "", "GGG" );
test_parse_var( $cds_rep, "chr3", 49395673, "GGCCGCCGCCGCCGCCGCC", "GGCCGCCGCCGCC" );
test_parse_var( $cds_delins, "chr1", 865533, "AG", "TC" );
test_parse_var( $cds_no_call, "chr1", 861319, 861320, "T", "N" );

my $cds_rna_delins_anno = bless(
    {
        'trInfo' => {
            'NM_006158.3' => {
                'c'             => 'c.1412_1413insT',
                'cdsBegin'      => '1413',
                'cdsEnd'        => '1413',
                'ei_Begin'      => 'EX3',
                'ei_End'        => 'EX3',
                'exin'          => 'EX3',
                'exonIndex'     => '3',
                'func'          => 'frameshift',
                'funcSO'        => 'SO:0001589',
                'funcSOname'    => 'frameshift_variant',
                'geneId'        => '4747',
                'geneSym'       => 'NEFL',
                'genepart'      => 'CDS',
                'genepartIndex' => '3',
                'genepartSO'    => 'SO:0000316',
                'intronIndex'   => '.',
                'p'             => 'p.S472fs*?',
                'prot'          => 'NP_006149.2',
                'protBegin'     => 471,
                'protEnd'       => 544,
                'r'             => 'C3',
                'r_Begin'       => 'C3',
                'r_End'         => 'C3',
                'rnaBegin'      => 1515,
                'rnaEnd'        => '1515',
                'strd'          => '-',
                'trAlt'         => 'TC',
                'trRef'         => 'C',
                'trRefComp'     => {
                    'EX3' => 1
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'A',
                'altlen'    => 1,
                'chr'       => '8',
                'end'       => 24811066,
                'gHGVS'     => 'g.24811065G>A',
                'guess'     => 'snv',
                'imp'       => 'snv',
                'pos'       => 24811065,
                'ref'       => 'G',
                'refbuild'  => 'GRCh37',
                'reflen'    => 1,
                'sm'        => 1,
                'varTypeSO' => 'SO:0001483'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);
my $cds_no_change_anno = bless(
    {
        'trInfo' => {
            'NM_006158.3' => {
                'c'             => 'c.=',
                'cdsBegin'      => '1414',
                'cdsEnd'        => '1413',
                'ei_Begin'      => 'EX3',
                'ei_End'        => 'EX3',
                'exin'          => 'EX3',
                'exonIndex'     => '3',
                'func'          => 'no-change',
                'funcSO'        => '',
                'funcSOname'    => 'no-change',
                'geneId'        => '4747',
                'geneSym'       => 'NEFL',
                'genepart'      => 'CDS',
                'genepartIndex' => '3',
                'genepartSO'    => 'SO:0000316',
                'intronIndex'   => '.',
                'prot'          => 'NP_006149.2',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'C3',
                'r_Begin'       => 'C3',
                'r_End'         => 'C3',
                'rnaBegin'      => '1516',
                'rnaEnd'        => '1515',
                'strd'          => '-',
                'trAlt'         => '',
                'trRef'         => '',
                'trRefComp'     => {
                    'EX3' => 0
                }
            }
        },
        'var' => bless(
            {
                'alt'       => '',
                'altlen'    => 0,
                'chr'       => '8',
                'end'       => 24811065,
                'gHGVS'     => 'g.24811065delG',
                'guess'     => 'del',
                'imp'       => 'del',
                'pos'       => 24811064,
                'ref'       => 'G',
                'refbuild'  => 'GRCh37',
                'reflen'    => 1,
                'sm'        => 1,
                'varTypeSO' => 'SO:0000159'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);
my $cds_snv_anno = bless(
    {
        'trInfo' => {
            'NM_006158.3' => {
                'c'             => 'c.1412C>A',
                'cc'            => 'CCC=>CAC',
                'cdsBegin'      => '1412',
                'cdsEnd'        => '1412',
                'ei_Begin'      => 'EX3',
                'ei_End'        => 'EX3',
                'exin'          => 'EX3',
                'exonIndex'     => '3',
                'func'          => 'missense',
                'funcSO'        => 'SO:0001583',
                'funcSOname'    => 'missense_variant',
                'geneId'        => '4747',
                'geneSym'       => 'NEFL',
                'genepart'      => 'CDS',
                'genepartIndex' => '3',
                'genepartSO'    => 'SO:0000316',
                'intronIndex'   => '.',
                'p'             => 'p.P471H',
                'polar'         => 'NP=>P+',
                'prot'          => 'NP_006149.2',
                'protBegin'     => 471,
                'protEnd'       => 471,
                'r'             => 'C3',
                'r_Begin'       => 'C3',
                'r_End'         => 'C3',
                'rnaBegin'      => 1514,
                'rnaEnd'        => 1514,
                'strd'          => '-',
                'trAlt'         => 'A',
                'trRef'         => 'C',
                'trRefComp'     => {
                    'EX3' => 1
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'T',
                'altlen'    => 1,
                'chr'       => '8',
                'end'       => 24811067,
                'gHGVS'     => 'g.24811066G>T',
                'guess'     => 'snv',
                'imp'       => 'snv',
                'pos'       => 24811066,
                'ref'       => 'G',
                'refbuild'  => 'GRCh37',
                'reflen'    => 1,
                'sm'        => 1,
                'varTypeSO' => 'SO:0001483'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);
my $cds_del_anno = bless(
    {
        'trInfo' => {
            'NM_006158.3' => {
                'c'             => 'c.1412delC',
                'cdsBegin'      => '1412',
                'cdsEnd'        => '1412',
                'ei_Begin'      => 'EX3',
                'ei_End'        => 'EX3',
                'exin'          => 'EX3',
                'exonIndex'     => '3',
                'func'          => 'frameshift',
                'funcSO'        => 'SO:0001589',
                'funcSOname'    => 'frameshift_variant',
                'geneId'        => '4747',
                'geneSym'       => 'NEFL',
                'genepart'      => 'CDS',
                'genepartIndex' => '3',
                'genepartSO'    => 'SO:0000316',
                'intronIndex'   => '.',
                'p'             => 'p.P471fs*?',
                'prot'          => 'NP_006149.2',
                'protBegin'     => 471,
                'protEnd'       => 544,
                'r'             => 'C3',
                'r_Begin'       => 'C3',
                'r_End'         => 'C3',
                'rnaBegin'      => 1514,
                'rnaEnd'        => 1514,
                'strd'          => '-',
                'trAlt'         => '',
                'trRef'         => 'C',
                'trRefComp'     => {
                    'EX3' => 1
                }
            }
        },
        'var' => bless(
            {
                'alt'       => '',
                'altlen'    => 0,
                'chr'       => '8',
                'end'       => 24811067,
                'gHGVS'     => 'g.24811067delG',
                'guess'     => 'del',
                'imp'       => 'del',
                'pos'       => 24811066,
                'ref'       => 'G',
                'refbuild'  => 'GRCh37',
                'reflen'    => 1,
                'sm'        => 1,
                'varTypeSO' => 'SO:0000159'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);
my $cds_ins_anno = bless(
    {
        'trInfo' => {
            'NM_006158.3' => {
                'c'             => 'c.1411_1412insCCC',
                'cdsBegin'      => '1412',
                'cdsEnd'        => '1411',
                'ei_Begin'      => 'EX3',
                'ei_End'        => 'EX3',
                'exin'          => 'EX3',
                'exonIndex'     => '3',
                'func'          => 'cds-ins',
                'funcSO'        => 'SO:0001821',
                'funcSOname'    => 'inframe_insertion',
                'geneId'        => '4747',
                'geneSym'       => 'NEFL',
                'genepart'      => 'CDS',
                'genepartIndex' => '3',
                'genepartSO'    => 'SO:0000316',
                'intronIndex'   => '.',
                'p'             => 'p.P471dup',
                'prot'          => 'NP_006149.2',
                'protBegin'     => 471,
                'protEnd'       => 471,
                'r'             => 'C3',
                'r_Begin'       => 'C3',
                'r_End'         => 'C3',
                'rnaBegin'      => 1514,
                'rnaEnd'        => 1513,
                'strd'          => '-',
                'trAlt'         => 'CCC',
                'trRef'         => '',
                'trRefComp'     => {
                    'EX3' => 0
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'GGG',
                'altlen'    => 3,
                'chr'       => '8',
                'end'       => 24811067,
                'gHGVS'     => 'g.24811067_24811068insGGG',
                'guess'     => 'ins',
                'imp'       => 'ins',
                'pos'       => 24811067,
                'ref'       => '',
                'refbuild'  => 'GRCh37',
                'reflen'    => 0,
                'sm'        => 0,
                'varTypeSO' => 'SO:0000667'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);
my $cds_rep_anno = bless(
    {
        'trInfo' => {
            'NM_000581.2' => {
                'c'             => 'c.21GGC[6>4]',
                'cdsBegin'      => '21',
                'cdsEnd'        => '38',
                'ei_Begin'      => 'EX1',
                'ei_End'        => 'EX1',
                'exin'          => 'EX1',
                'exonIndex'     => '1',
                'func'          => 'cds-del',
                'funcSO'        => 'SO:0001822',
                'funcSOname'    => 'inframe_deletion',
                'geneId'        => '2876',
                'geneSym'       => 'GPX1',
                'genepart'      => 'CDS',
                'genepartIndex' => '1',
                'genepartSO'    => 'SO:0000316',
                'intronIndex'   => '.',
                'p'             => 'p.A7[7>5]',
                'prot'          => 'NP_000572.2',
                'protBegin'     => 7,
                'protEnd'       => 13,
                'r'             => 'C1',
                'r_Begin'       => 'C1',
                'r_End'         => 'C1',
                'rnaBegin'      => 101,
                'rnaEnd'        => 118,
                'strd'          => '-',
                'trAlt'         => 'GGCGGCGGCGGC',
                'trRef'         => 'GGCGGCGGCGGCGGCGGC',
                'trRefComp'     => {
                    'EX1' => 18
                }
            },
            'NM_201397.1' => {
                'c'             => 'c.21GGC[6>4]',
                'cdsBegin'      => '21',
                'cdsEnd'        => '38',
                'ei_Begin'      => 'EX1E',
                'ei_End'        => 'EX1E',
                'exin'          => 'EX1E',
                'exonIndex'     => '1',
                'func'          => 'cds-del',
                'funcSO'        => 'SO:0001822',
                'funcSOname'    => 'inframe_deletion',
                'geneId'        => '2876',
                'geneSym'       => 'GPX1',
                'genepart'      => 'CDS',
                'genepartIndex' => '1',
                'genepartSO'    => 'SO:0000316',
                'intronIndex'   => '.',
                'p'             => 'p.A7[7>5]',
                'prot'          => 'NP_958799.1',
                'protBegin'     => 7,
                'protEnd'       => 13,
                'r'             => 'C1E',
                'r_Begin'       => 'C1E',
                'r_End'         => 'C1E',
                'rnaBegin'      => 101,
                'rnaEnd'        => 118,
                'strd'          => '-',
                'trAlt'         => 'GGCGGCGGCGGC',
                'trRef'         => 'GGCGGCGGCGGCGGCGGC',
                'trRefComp'     => {
                    'EX1E' => 18
                }
            }
        },
        'var' => bless(
            {
                '+' => {
                    'ba'  => '',
                    'bal' => 0,
                    'bp'  => 49395685,
                    'br'  => 'GCCGCC',
                    'brl' => 6
                },
                '-' => {
                    'ba'  => '',
                    'bal' => 0,
                    'bp'  => 49395673,
                    'br'  => 'GCCGCC',
                    'brl' => 6
                },
                'a'         => 'GCCGCCGCCGCC',
                'al'        => 12,
                'alt'       => 'GCCGCCGCCGCC',
                'alt_cn'    => 4,
                'altlen'    => 12,
                'chr'       => '3',
                'end'       => 49395691,
                'gHGVS'     => 'g.49395674GCC[6>4]',
                'guess'     => 'delins',
                'imp'       => 'rep',
                'p'         => 49395673,
                'pos'       => 49395673,
                'r'         => 'GCCGCCGCCGCCGCCGCC',
                'ref'       => 'GCCGCCGCCGCCGCCGCC',
                'ref_cn'    => 6,
                'refbuild'  => 'GRCh37',
                'reflen'    => 18,
                'rep'       => 'GCC',
                'replen'    => 3,
                'rl'        => 18,
                'sm'        => 2,
                'varTypeSO' => 'SO:1000032'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);
my $cds_delins_anno = bless(
    {
        'trInfo' => {
            'NM_152486.2' => {
                'c'             => 'c.73-2_73-1delinsTC',
                'cdsBegin'      => '73-2',
                'cdsEnd'        => '73-1',
                'ei_Begin'      => 'IVS2',
                'ei_End'        => 'IVS2',
                'exin'          => 'IVS2',
                'exonIndex'     => '.',
                'func'          => 'splice-3',
                'funcSO'        => '',
                'funcSOname'    => 'unknown-likely-deleterious',
                'geneId'        => '148398',
                'geneSym'       => 'SAMD11',
                'genepart'      => 'three_prime_cis_splice_site',
                'genepartIndex' => '2',
                'genepartSO'    => 'SO:0000164',
                'intronIndex'   => '2',
                'prot'          => 'NP_689699.2',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'AC1',
                'r_Begin'       => 'AC1',
                'r_End'         => 'AC1',
                'rnaBegin'      => '153-2',
                'rnaEnd'        => '153-1',
                'strd'          => '+',
                'trAlt'         => 'TC',
                'trRef'         => 'AG',
                'trRefComp'     => {
                    'IVS2' => [ 0, 2 ]
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'TC',
                'altlen'    => 2,
                'chr'       => '1',
                'end'       => 865534,
                'gHGVS'     => 'g.865533_865534delAGinsTC',
                'guess'     => 'delins',
                'imp'       => 'delins',
                'pos'       => 865532,
                'ref'       => 'AG',
                'refbuild'  => 'GRCh37',
                'reflen'    => 2,
                'sep_snvs'  => [ 865533, 865534 ],
                'sm'        => 3,
                'varTypeSO' => 'SO:1000032'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);
my $cds_no_call_anno = bless(
    {
        'trInfo' => {
            'NM_152486.2' => {
                'c'             => 'c.-2T>N',
                'cdsBegin'      => '-2',
                'cdsEnd'        => '-2',
                'ei_Begin'      => 'EX2',
                'ei_End'        => 'EX2',
                'exin'          => 'EX2',
                'exonIndex'     => '2',
                'func'          => 'utr-5',
                'funcSO'        => '',
                'funcSOname'    => 'unknown',
                'geneId'        => '148398',
                'geneSym'       => 'SAMD11',
                'genepart'      => 'five_prime_UTR',
                'genepartIndex' => '2',
                'genepartSO'    => 'SO:0000204',
                'intronIndex'   => '.',
                'prot'          => 'NP_689699.2',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => '5U1',
                'r_Begin'       => '5U1',
                'r_End'         => '5U1',
                'rnaBegin'      => 79,
                'rnaEnd'        => 79,
                'strd'          => '+',
                'trAlt'         => 'N',
                'trRef'         => 'T',
                'trRefComp'     => {
                    'EX2' => 1
                }
            },
            'NR_026874.1' => {
                'c'             => 'n.-6503A>N',
                'cdsBegin'      => '',
                'cdsEnd'        => '',
                'ei_Begin'      => '.',
                'ei_End'        => '.',
                'exin'          => '.',
                'exonIndex'     => '.',
                'func'          => 'promoter',
                'funcSO'        => '',
                'funcSOname'    => 'unknown',
                'geneId'        => '100130417',
                'geneSym'       => 'LOC100130417',
                'genepart'      => 'promoter',
                'genepartIndex' => 0,
                'genepartSO'    => 'SO:0000167',
                'intronIndex'   => '.',
                'prot'          => '',
                'protBegin'     => '',
                'protEnd'       => '',
                'r'             => 'PROM',
                'r_Begin'       => 'PROM',
                'r_End'         => 'PROM',
                'rnaBegin'      => -6503,
                'rnaEnd'        => -6503,
                'strd'          => '-',
                'trAlt'         => 'N',
                'trRef'         => 'A',
                'trRefComp'     => {
                    'P0' => [ 0, 1 ]
                }
            }
        },
        'var' => bless(
            {
                'alt'       => 'N',
                'altlen'    => 1,
                'chr'       => '1',
                'end'       => 861320,
                'gHGVS'     => 'g.861319T>N',
                'guess'     => 'no-call',
                'imp'       => 'snv',
                'pos'       => 861319,
                'ref'       => 'T',
                'refbuild'  => 'GRCh37',
                'reflen'    => 1,
                'sm'        => 1,
                'varTypeSO' => 'no-call'
            },
            'BedAnno::Var'
        )
    },
    'BedAnno::Anno'
);

test_varanno( $cds_rna_delins_anno, $cds_rna_delins );
test_varanno( $cds_no_change_anno, $cds_no_change );
test_varanno( $cds_snv_anno, $cds_snv );
test_varanno( $cds_del_anno, $cds_del );
test_varanno( $cds_ins_anno, $cds_ins );
test_varanno( $cds_rep_anno, $cds_rep );
test_varanno( $cds_delins_anno, $cds_delins );
test_varanno( $cds_no_call_anno, $cds_no_call );

done_testing();
exit 0;

sub test_parse_var {
    my ($expect,@args) = @_;
    my $ranno = BedAnno::Var->new(@args);
    if (!is_deeply($ranno, $expect, "for [ ".join(",",@args)." ]")) {
        explain "The anno infomations are: ", $ranno;
    }
}

sub test_varanno{
    my ($expect, $vara)=@_;
    my ($vAnno, $noneed) = $beda->varanno($vara);
    if (!is_deeply ($vAnno,$expect,"for [ $vara->{imp} ]")){
	explain "The anno infomations are: ", $vAnno;
    }
}

# test if the tabix is available
sub test_tabix {
    my ($file) = @_;
    my $cmd;
    $cmd = "tabix -f -p bed $file";
    system($cmd);
    if ( !is( $?, 0, "tabix .. $cmd" ) ) {
        exit 1;
    }
}
