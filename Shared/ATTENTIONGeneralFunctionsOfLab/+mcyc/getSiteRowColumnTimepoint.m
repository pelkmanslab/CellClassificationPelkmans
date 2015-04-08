function SiteRowColumnTimepoint = getSiteRowColumnTimepoint(strFileName)

[intSite] = check_image_position(strFileName);
[intRow, intColumn,~, intTimepoint] = filterimagenamedata(strFileName);

SiteRowColumnTimepoint = [intSite intRow intColumn intTimepoint];

end