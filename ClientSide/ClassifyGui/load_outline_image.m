%function outlines=load_outline_image(path)
path='Z:\Data\Users\Lilli\adhesome_screen_data_new_analysis\080214_Lilli_A431cavgfp_ChT_phal_screen_CP074-1aa\BATCH\080214_Lilli_A431cavgfp_ChT_phal_sceen_1_K14_16_w460_SegmentedNuclei.png';

im=imread(path);
foo=edge(double(im>0));
imagesc(foo);

