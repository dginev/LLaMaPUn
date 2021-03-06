use strict;
use warnings;
use utf8;

use Test::More tests => 9;

use XML::LibXML;
use LLaMaPUn::Preprocessor;
use LLaMaPUn::Preprocessor::Purify;
use LLaMaPUn::Preprocessor::MarkTokens;
use Scalar::Util qw/blessed/;

# Generated via:
# latexmlc --preload=[ids]latexml.sty --nopost --parse=no --nocomments --nodefaultresources --timestamp=0 $tex_fragment
my $tex_fragment = "t/documents/sample_document.tex";

my $parser=XML::LibXML->new(no_blanks=>1);
$parser->load_ext_dtd(0);
my $test_fragment = "t/documents/sample_document.xml";
my $test_dom = $parser->parse_file($test_fragment);
my $planetmath_doc = "t/documents/entry216.xml";
my $planetmath_dom = $parser->parse_file($planetmath_doc);
my $test_arxiv_doc = "t/documents/1311.6767.xml";
my $test_arxiv_dom = $parser->parse_file($test_arxiv_doc);

# Purification tests:
my $test_purified_dom = LLaMaPUn::Preprocessor::Purify::purify_noparse($test_dom,verbose=>0);
my $test_saved_dom = $test_purified_dom->cloneNode(1);

my $planetmath_purified_dom = LLaMaPUn::Preprocessor::Purify::purify_noparse($planetmath_dom,verbose=>0);
my $planetmath_saved_dom = $planetmath_purified_dom->cloneNode(1);

my $purified_arxiv_dom = LLaMaPUn::Preprocessor::Purify::purify_noparse($test_arxiv_dom,verbose=>0);
my $arxiv_saved_dom = $purified_arxiv_dom->cloneNode(1);

my $preprocessor=LLaMaPUn::Preprocessor->new(replacemath=>"position");
# Preprocess, Test I
$preprocessor->setDocument($test_purified_dom);

my $abstract = $preprocessor->getNormalizedElement('abstract');
#my $titles = $preprocessor->getNormalizedElements('title');
my $body = $preprocessor->getNormalizedBody;

is($$abstract,"A test for LLaMaPUn::Preprocessor","Simple test abstract");
is($$body,"This is a sample sentence with ASCII MathExpr-doc0-purify0-m1 math. And a MathExpr-doc0-S1-p1-p1-m1 square root. "
         ."And then an example of text in math MathExpr-doc0-S1-p1-p1-m2. "
         ."A trickier test of tokenization- how about MathExpr-doc0-S1-p1-p1-m3 -convergent?","Simple test body");

# Test the math lookup table
my $second_math = $preprocessor->getEntry('MathExpr-doc0-S1-p1-p1-m2');
# AND test if the purifier found "jaguar" and "mouse" and united them
is($second_math->toString,'<Math mode="inline" xml:id="S1.p1.1.m2" tex="P(jaguar\mid mouse)=0"><XMath xml:id="S1.p1.1.m2.1"><XMTok role="UNKNOWN" xml:id="S1.p1.1.m2.1.1" font="italic">P</XMTok><XMTok role="OPEN" xml:id="S1.p1.1.m2.1.2">(</XMTok><XMTok role="UNKNOWN" meaning="UNKNOWN" font="italic">jaguar</XMTok><XMTok name="mid" role="VERTBAR" xml:id="S1.p1.1.m2.1.9">∣</XMTok><XMTok role="UNKNOWN" meaning="UNKNOWN" font="italic">mouse</XMTok><XMTok role="CLOSE" xml:id="S1.p1.1.m2.1.15">)</XMTok><XMTok meaning="equals" role="RELOP" xml:id="S1.p1.1.m2.1.16">=</XMTok><XMTok meaning="0" role="NUMBER" xml:id="S1.p1.1.m2.1.17">0</XMTok></XMath></Math>',
  "Simple test math map");

# Preprocess, Test II
$preprocessor->setDocument($planetmath_purified_dom);
$abstract = $preprocessor->getNormalizedElement('abstract');
#my $titles = $preprocessor->getNormalizedElements('title');
$body = $preprocessor->getNormalizedBody;
$second_math = $preprocessor->getEntry('MathExpr-doc0-p1-p1-m2');
is(blessed($second_math),'XML::LibXML::Element','PlanetMath test math map');
my $ref = $preprocessor->getEntry('ourreference-doc0-r0');
is($ref->toString,'<ref href="http://planetmath.org/CumulativeDistributionFunction" about="" property="pm:linksTo" resource="pmarticle:CumulativeDistributionFunction">cumulative distribution function</ref>',"PlanetMath ref map");

# Preprocess, Test III
$preprocessor->setDocument($purified_arxiv_dom);
$abstract = $preprocessor->getNormalizedElement('abstract');
$body = $preprocessor->getNormalizedBody;
$second_math = $preprocessor->getEntry('MathExpr-doc0-p1-p1-m2');
is(blessed($second_math),'XML::LibXML::Element',"arXiv test math map");

#print STDERR "Tokenized Dom: \n",$test_purified_dom->toString(1),"\n\n";
# MarkTokens, Test I
my $marktokens = LLaMaPUn::Preprocessor::MarkTokens->new(document=>$test_saved_dom);
my $test_tokenized_dom = $marktokens->process_document;
my $test_expected_tokenized = $parser->parse_file("t/documents/sample_tokenized.xml");
is($test_tokenized_dom->toString(1),$test_expected_tokenized->toString(1),"Simple test MarkTokens");

# MarkTokens, Test II
$marktokens = LLaMaPUn::Preprocessor::MarkTokens->new(document=>$planetmath_saved_dom);
my $planetmath_tokenized_dom = $marktokens->process_document;
my $planetmath_expected_tokenized = $parser->parse_file("t/documents/entry216_tokenized.xml");
is($planetmath_tokenized_dom->toString(1),$planetmath_expected_tokenized->toString(1),"PlanetMath test MarkTokens");

# MarkTokens, Test III
$marktokens = LLaMaPUn::Preprocessor::MarkTokens->new(document=>$arxiv_saved_dom);
my $arxiv_tokenized_dom = $marktokens->process_document;
my $arxiv_expected_tokenized = $parser->parse_file("t/documents/1311.6767_tokenized.xml");
is($arxiv_tokenized_dom->toString(1),$arxiv_expected_tokenized->toString(1),"arXiv test MarkTokens");

# open O, ">", '/tmp/test.xml';
# print O $arxiv_tokenized_dom->toString(1);
# close O;