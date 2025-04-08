# Methodology

Four versions of the test project build were tested one after the other on three servers (without compression, with gzip and with brotli):

Each version was run the same number of times, from one point at approximately the same time. Loading time was measured using Chrome DevTools.

## Versions

- Plugin disabled, no debug information
- Plugin disabled, debug information included
- Plugin enabled, no debug information
- Plugin enabled, debug information included

## Servers

1. **No compression** - average Apache server
2. **gzip** - itch.io
3. **brotli** - custom Node.js server

<br/>
<br/>

# Results

## Overall summary

**The speed gain can range from 10 to 100%.**
<br/>
The plugin increases the speed of downloading the bundle, regardless of the compression method used on the server. There are some problems with .pck files when using gzip, but overall the final gain is still greater than without using the plugin.

<br/>

## Summary table for the builds without debug info
					
| File || File size || Average download time	||
|---|-|---|:-:|:-:|:-:|
||||no compression | gzip | brotli
|.wasm
|| w/o plugin | 42,7 Mb | 4,71 s. | 4,27 s. | 2,01 s.
|| w/ plugin | 9,3 Mb | 1,00 s. | 1,21 s. | 1,18 s.
|| speed up|| 3,71 s.<br/>_+370,50%_<br/>**x4,7 faster** | 3,06 s.<br/>_+252,89%_<br/>**x3,5 faster** | 0,83 s.<br/>_+70,34%_<br/>**x1,7 faster** |
|.pck					
|| w/o plugin | 21,0 Mb | 6,02 s. | 2,34 s. | 2,27 s.
|| w/ plugin | 19,3 Mb | 2,73 s. | 2,68 s. | 2,22 s.
|| speed up	|| 3,29 s.<br/>_+120,47%_<br/>**x2,2 faster** | -0,34 s.<br/>_-12,73%_<br/>**x1,1 slower** | 0,05 s.<br/>_+2,20%_<br/>**~ same** |
| Game Start					
|| w/o plugin || 8,89 s. | 7,22 s. | 4,53 s.
|| w/ plugin || 4,37 s. | 6,44 s. | 3,86 s.
|| speed up || 4,52 s.<br/>_+103,43%_<br/>**x2,0 faster** |	0,78 s.<br/>_+12,11%_<br/>**x1,1 faster** | 0,67 s.<br/>_+17,36%_<br/>**x1,2 faster** |

<br/>

## Summary table for the builds with debug info
					
| File || File size || Average download time	||
|---|-|---|:-:|:-:|:-:|
||||no compression | gzip | brotli
|.wasm
|| w/o plugin | 50,9 Mb | 6,59 s. | 6,11 s. | 2,00 s.
|| w/ plugin | 10,5 Mb | 1,19 s. | 1,40 s. | 1,32 s.
|| speed up || 5,40 s.<br/>_+453,78%_<br/>**x5,5 faster** | 4,71 s.<br/>_+336,43%_<br/>**x4,4 faster** | 0,68 s.<br/>_+51,52%_<br/>**x1,5 faster** |
|.pck					
|| w/o plugin | 21,0 Mb | 3,23 s. | 2,58 s. | 2,34 s.
|| w/ plugin | 19,3 Mb | 2,94 s. | 2,78 s. | 2,36 s.
|| speed up || 0,29 s.<br/>_+9,86%_<br/>**x1,1 faster** |-0,20 s.<br/>_-7,19%_**x1,1 slower** |-0,02 s.<br/>_-0,85%_|**~ same**|
| Game Start					
|| w/o plugin || 9,28 s. | 9,65 s. | 4,74 s.
|| w/ plugin || 5,93 s. | 5,81 s. | 4,00 s.
|| speed up || 3,35 s.<br/>_+56,49%_<br/>**x1,6 faster** | 3,84 s.<br/>_+66,09%_<br/>**x1,7 faster** |0,74 s.<br/>_+18,50%_<br/>**x1,2 faster** |

<br/>
<br/>

## Average requests table

| debug info|||||||||w/o debug||||||||||||||||||with debug ||||||||||
| - | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| server compression|||no compression||||||gzip||||||brotli||||||no compression||||||gzip||||||brotli||||
| file | .wasm || .pck || Game start || .wasm || .pck || Game start || .wasm || .pck || Game start || .wasm || .pck || Game start || .wasm || .pck || Game start || .wasm || .pck || Game start ||
| plugin enabled | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ | \- | \+ |
| | 5,22 | 0,99 | 6,04 | 2,72 | 8,33 | 5,43 | 4,5 | 1,55 | 2,42 | 2,87 | 7,69 | 5,5 | 2,13 | 1,1 | 2,53 | 2,12 | 4,9 | 3,76 | 5,41 | 1,42 | 6,67 | 3,28 | 9,28 | 5,06 | 5,88 | 1,37 | 2,45 | 2,75 | 9,25 | 5,95 | 2,09 | 1,31 | 2,35 | 2,35 | 4,93 | 4,07
| | 4,62 | 1,01 | 5,84 | 2,76 | 8,27 | 5,47 | 5,11 | 1,18 | 2,32 | 2,61 | 9,29 | 6,09 | 2,06 | 1,1 | 2,39 | 2,17 | 3,55 | 2,82 | 5,36 | 1,18 | 6,64 | 2,99 | 9,33 | 6 | 6,04 | 1,4 | 2,31 | 2,79 | 9,08 | 5,77 | 2,29 | 1,23 | 2,51 | 2,34 | 5,15 | 5,19
| | 4,8 | 1,01 | 6,07 | 2,7 | 8,39 | 5,53 | 5,6 | 1,15 | 2,32 | 2,66 | 8,77 | 5,36 | 1,72 | 1,4 | 2,06 | 2,43 | 4,32 | 4,12 | 5,39 | 1,21 | 6,68 | 3,41 | 9,15 | 7,34 | 5,72 | 1,37 | 2,32 | 2,76 | 9,07 | 5,74 | 2,08 | 1,23 | 2,39 | 2,3 | 4,93 | 5,24
| | 4,62 | 1 | 5,94 | 2,83 | 8,26 | 5,49 | 6,3 | 1,19 | 2,24 | 2,72 | 9,8 | 5,48 | 1,94 | 1,38 | 2,3 | 2,41 | 3,5 | 4,06 | 5,29 | 1,16 | 6,61 | 2,91 | 9,13 | 4,61 | 5,63 | 1,43 | 2,42 | 2,76 | 8,9 | 5,77 | 2,04 | 1,31 | 2,38 | 2,36 | 4,86 | 5,31
| | 4,51 | 1 | 5,95 | 2,74 | 8,18 | 5,46 | 5,26 | 1,16 | 2,37 | 2,65 | 9,42 | 5,48 | 1,82 | 1,09 | 2,17 | 2,22 | 4,4 | 4,92 | 5,38 | 1,14 | 6,66 | 2,93 | 9,18 | 4,75 | 5,79 | 1,47 | 2,29 | 2,75 | 9,71 | 5,78 | 2,11 | 1,4 | 2,56 | 2,53 | 5,01 | 4,29
| | 4,49 | 1,04 | 5,88 | 2,79 | 8,15 | 4,64 | 4,88 | 1,26 | 2,32 | 2,67 | 7,77 | 6,3 | 1,95 | 1,15 | 2,28 | 2,17 | 4,46 | 4 | 5,44 | 1,12 | 6,68 | 2,9 | 9,19 | 4,59 | 5,98 | 1,37 | 2,36 | 2,74 | 9,16 | 5,74 | 2,07 | 1,3 | 2,37 | 2,41 | 4,84 | 4,16
| | 4,52 | 0,98 | 5,87 | 2,62 | 8 | 4,32 | 4,57 | 1,19 | 2,33 | 2,69 | 7,98 | 6,01 | 1,76 | 1,11 | 2,12 | 2,14 | 3,31 | 3,74 | 5,91 | 1,13 | 6,6 | 2,95 | 9,17 | 5,97 | 5,56 | 1,48 | 2,43 | 2,86 | 8,66 | 5,89 | 1,97 | 1,35 | 2,33 | 2,36 | 4,79 | 4,05
| | 4,51 | 1 | 6,04 | 2,77 | 8,26 | 4,48 | 5,54 | 1,16 | 2,27 | 2,63 | 8,43 | 5,58 | 2,01 | 1,12 | 2,35 | 2,18 | 4,57 | 4,78 | 5,4 | 1,12 | 6,66 | 2,99 | 9,79 | 5,94 | 6,38 | 1,47 | 2,36 | 2,79 | 9,4 | 5,81 | 2,15 | 1,33 | 2,38 | 2,38 | 4,88 | 5,34
| | 4,54 | 0,99 | 5,93 | 2,7 | 8,1 | 5,44 | 4,41 | 1,19 | 2,38 | 2,66 | 7,2 | 5,44 | 1,71 | 1,16 | 2,15 | 2,19 | 4,34 | 3,84 | 5,3 | 1,14 | 6,57 | 2,91 | 9,18 | 5,84 | 6,06 | 1,62 | 2,38 | 2,82 | 9,24 | 5,78 | 2,28 | 1,47 | 2,63 | 2,54 | 4,09 | 4,21
| | 5,22 | 0,98 | 6,65 | 2,68 | 8,89 | 4,37 | 4,27 | 1,21 | 2,41 | 2,63 | 7,22 | 6,44 | 2,01 | 1,18 | 2,37 | 2,2 | 4,53 | 3,86 | 6,59 | 1,19 | 3,23 | 2,94 | 9,28 | 5,93 | 6,11 | 1,4 | 2,58 | 2,78 | 9,65 | 5,81 | 2 | 1,32 | 2,34 | 2,36 | 4,74 | 4 |				
||||||||||||||||||||||||||||||||||||||
||||||||||||||||||||||||||||||||||||||
| Average |4,705|1|6,021|2,731|8,283|5,063|5,044|1,224|2,338|2,679|8,357|5,768|1,911|1,179|2,272|2,223|4,188|3,99|5,547|1,181|6,3|3,021|9,268|5,603|5,915|1,438|2,39|2,78|9,212|5,804|2,108|1,325|2,424|2,393|4,822|4,586
| Speed up ||+371%||+120%||+64%||+312%||-13%||+45%||+62%||+2%||+5%||+370%||+109%||+65%||+311%||-14%||+59%||+59%||+1%||+5%|
| Faster times ||x4,71||x2,20||x1,64||x4,12||x0,87||x1,45||x1,62||x1,02||x1,05||x4,70||x2,09||x1,65||x4,11||x0,86||x1,59||x1,59||x1,01||x1,05	