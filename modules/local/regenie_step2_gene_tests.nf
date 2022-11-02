process REGENIE_STEP2_GENE_TESTS {

  publishDir "${params.outdir}/logs", mode: 'copy', pattern: '*.log'
  publishDir "${params.outdir}/masks", mode: 'copy', pattern: '*masks*.{txt,snplist,bed,bim,fam}'

  input:
    path step1_out
    tuple val(filename), path(genotyped_plink_file)
    val assoc_format
	  path phenotypes_file
    path covariates_file
    path regenie_gene_anno_file
    path regenie_gene_setlist_file
    path regenie_gene_masks_file

  output:
    tuple val(filename), path("*regenie.gz"), emit: regenie_step2_out
    path "${filename}.log", emit: regenie_step2_out_log
    path "${filename}_masks*"

  script:
    def format = assoc_format == 'bed' ? "--bed" : '--bgen'
    def extension = assoc_format == 'bgen' ? ".bgen" : ''
    def firthApprox = params.regenie_firth_approx ? "--approx" : ""
    def firth = params.regenie_firth ? "--firth $firthApprox" : ""
    def binaryTrait =  params.phenotypes_binary_trait ? "--bt $firth " : ""
    def covariants = covariates_file ? "--covarFile $covariates_file --covarColList ${params.covariates_columns}" : ''
    def predictions = params.regenie_skip_predictions  ? '--ignore-pred' : ""
    def refFirst = params.regenie_ref_first  ? "--ref-first" : ''
    def geneTest = params.regenie_gene_test ? "--vc-tests ${params.regenie_gene_test}":''
    def aaf = params.regenie_gene_aaf ? "--aaf-bins ${params.regenie_gene_aaf}":''
    def maxAaf = params.regenie_gene_vc_max_aaf ? "--vc-maxAAF ${params.regenie_gene_vc_max_aaf}":''
    def vcMACThr = params.regenie_gene_vc_mac_thr ? "--vc-MACthr ${params.regenie_gene_vc_mac_thr}":''
    def buildMask = params.regenie_gene_build_mask ? "--build-mask ${params.regenie_gene_build_mask}":''
    def writeMasks = params.regenie_write_bed_masks  ? "--write-mask" : ''
    def joint = params.regenie_gene_joint ? "--joint ${params.regenie_gene_joint}":''

  """
  regenie \
    --step 2 \
    $format ${filename}${extension} \
    --phenoFile ${phenotypes_file} \
    --phenoColList  ${params.phenotypes_columns} \
    --bsize ${params.regenie_bsize_step2} \
    --pred regenie_step1_out_pred.list \
    --anno-file ${regenie_gene_anno_file} \
    --set-list ${regenie_gene_setlist_file} \
    --mask-def ${regenie_gene_masks_file} \
    --threads ${task.cpus} \
    --gz \
    --check-burden-files \
    --write-mask-snplist \
    $writeMasks \
    $binaryTrait \
    $covariants \
    $predictions \
    $geneTest \
    $aaf \
    $maxAaf \
    $vcMACThr \
    $buildMask \
    $joint \
    --out ${filename}
  """
}
