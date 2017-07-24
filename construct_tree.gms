$STITLE Construct Two-Stage Tree
$ontext
+ LICENSE +
This work is licensed under the MIT License (MIT).

The MIT License (MIT)
Copyright (c) 2016 Friedrich Kunz (DIW Berlin) and Jan Abrell (ETH Zurich)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


+ CITATION +
Whenever you use this code, please refer to
Abrell, J. and Kunz, F. (2015):
Integrating Intermittent Renewable Wind Generation - A Stochastic Multi-Market
Electricity Model for the European Electricity Market
Networks and Spatial Economics 15(1), pp. 117-147.
http://link.springer.com/article/10.1007/s11067-014-9272-4


+ CONTACT +
Friedrich Kunz, DIW Berlin, fkunz@diw.de, phone: +49(0)30 89789 495

$offtext

set
         h               forcast hours
         k               nodes in stochastic tree
         root(k)         root node
         stage(k,h)      mapping of nodes to forecast hours
         stage2(k,t)     mapping of nodes to optimization horizon
         leaf(k)         leaf nodes
         ances_full(k,k) all direct and indirect predecessor nodes in initial tree
         ances_ini(k,k)  first are all predecessor nodes in initial tree of second
         ances_red(tau,k,k) first are all predecessor nodes in reduced tree of second for time period tau
         pred(k,k)       first is direct predecessor of second (assigned in prepare_id)
         ances(k,k)      first are all predecessor nodes in tree of second (assigned in prepare_id)
         mapkt(k,t)      mapping nodes to periods (assigned in prepare_id)
         mmapkt(k,t)     alias of mapkt (assigned in prepare_id)
;

parameter
         tree_upload     tree upload parameter
         ren_frc         renewable forecast
         ren_frc_prob    renewable forecast probability
         prob            node probability
;

alias(k,kk,kkk);

$onecho >temp.tmp
set=h            rng=ScenarioTree!A2         rdim=1 cdim=0
set=k            rng=ScenarioTree!C2         rdim=1 cdim=0
set=root         rng=ScenarioTree!I2         rdim=1 cdim=0
set=stage        rng=ScenarioTree!C2         rdim=2 cdim=0
set=leaf         rng=ScenarioTree!J2         rdim=1 cdim=0
set=ances_ini    rng=ScenarioTree!L2         rdim=2 cdim=0
par=tree_upload  rng=ScenarioTree!C1         rdim=2 cdim=1
$offecho

$onUNDF
$ifi %xls_upload%=="YES" $call "gdxxrw %datadir%%data%.xls O=%renewable% cmerge=1 @temp.tmp"
$gdxin %renewable%
$load h k root stage leaf ances_ini
$load tree_upload
$offUNDF

*$gdxin %datadir%%renewable%.gdx
*$load h, k=tree_n, root=tree_root, stage=tree_stage, leaf=tree_leaf, ances_ini=tree_anc, ances_red=result_tree_anc_r
*$load ren_frc
*$load ren_frc_prob
*;

ances_red(tau,k,kk) = ances_ini(k,kk);
ren_frc(c,ren,tau,h,k)$stage(k,h) = sum(ttau$(ord(ttau) eq ord(tau) + ord(h) - 1), ren_rel(ttau,c,ren));
ren_frc(c,'wind onshore',tau,h,k)$stage(k,h) = max(min(sum(ttau$(ord(ttau) eq ord(tau) + ord(h) - 1), ren_rel(ttau,c,'wind onshore')) + tree_upload(k,h,'Forecast error')*countryup(c,"Capacity",'wind onshore'),countryup(c,"Capacity",'wind onshore')),0);
ren_frc(c,'wind offshore',tau,h,k)$stage(k,h) = max(min(sum(ttau$(ord(ttau) eq ord(tau) + ord(h) - 1), ren_rel(ttau,c,'wind offshore')) + tree_upload(k,h,'Forecast error')*countryup(c,"Capacity",'wind offshore'),countryup(c,"Capacity",'wind onshore')),0);
ren_frc_prob(tau,h,k)$stage(k,h) = tree_upload(k,h,'Probability');

stage2(k,t)$sum(h$(ord(h) eq ord(t)), stage(k,h)) = YES;

ances_full(root,k) = YES;
loop(h,
         ances_full(k,kk)$(not root(k) and not root(kk) and ord(kk) eq ord(k) + ord(h)*card(leaf)) = YES;
);

*$stop
