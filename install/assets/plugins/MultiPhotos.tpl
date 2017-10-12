///defined('IN_MANAGER_MODE') or die();

global $content,$default_template,$tmplvars;
$tvIds = isset($tvIds) ? $tvIds : 0;
$w = isset($w) ? $w : 160;
$h = isset($h) ? $h : 120;
$templ = isset($templ) ? explode(',',$templ) : false;
$role = isset($role) ? explode(',',$role) : false;
$style = (isset($w) || isset($h)) ? ' "max-width":"{$w}px", "max-height":"{$h}px", "cursor":"pointer" ' : '';
$styleBool = (isset($w) || isset($h)) ? true : false;
$site = $modx->config['site_url'];
$thumbUrl = isset($thumbUrl) ? 'url = (url != "") ? ("'.$thumbUrl.'?src="+escape(url)+"&w='.$w.'&h='.$h.'") : url; ' : 'url = (url != "" && url.search(/http:\/\//i) == -1) ? ("'.$site.'" + url) : url;';
$cur_templ = isset($_POST['template']) ? $_POST['template'] : (isset($content['template']) ? $content['template'] : $default_template);
$cur_role = $_SESSION['mgrRole'];
if (($templ && !in_array($cur_templ,$templ)) || ($role && !in_array($cur_role,$role))) return;

$resize = isset($resize)&&($resize=='true') ? 1 : 0;
$crop = isset($crop)&&($crop=='true') ? 1 : 0;
$prefix = isset($prefix) ? $prefix : 's_';
$auto_big = isset($auto_big)&&($auto_big=='true') ? 1 : 0;
$auto_small = isset($auto_small)&&($auto_small=='true') ? 1 : 0;

$lang['insert']='Вставить';
$lang['url']='Путь:';
$lang['link']='Ссылка или большая картинка:';
$lang['title']='Название:';

$e = &$modx->Event;
if ($e->name == 'OnDocFormRender') {
require_once(MODX_MANAGER_PATH.'includes/tmplvars.inc.php');
$modx_script = renderFormElement('image',0,'','','');
preg_match('/(<script[^>]*?>.*?<\/script>)/si', $modx_script, $matches);
$output = $matches ? $matches[0] : '';
$output .= <<< OUT
<!-- MultiPhotos -->
<style type="text/css">
.fotoitem {border:1px solid #e3e3e3; margin:0 0 5px; padding:2px 5px 5px 5px; position:relative; overflow:hidden; white-space:nowrap; zoom:1}
.fotoitem span {display:inline-block; padding-top:3px;}
.fotoitem input {line-height:1.1; vertical-align:middle;}
.fotoitem input.imageField_multiphotos {width: 50%; max-width: 50%; min-width: 300px;}
.fotoitem:first-child input.fotoitemDel{display:none;}
.fotoimg {position:absolute; right:0; padding-top:3px;}
</style>
<script type="text/javascript">
window.ie9=window.XDomainRequest && window.performance; window.ie=window.ie && !window.ie9; /* IE9 patch */
!window.jQuery.ui && document.write(decodeURIComponent('%3Cscript%20src%3D%22https%3A%2F%2Fcode.jquery.com%2Fui%2F1.12.1%2Fjquery-ui.js%22%3E%3C%2Fscript%3E'));
var MultiPhotos = new Class({
	initialize: function(fid){
		this.nameJQ = fid;
		this.fidJQ = jQuery('#'+fid);
		var hpArrJQ = (this.fidJQ.val() && this.fidJQ.val()!='[]') ? Json.evaluate(this.fidJQ.val()) : [null];
		this.fidJQ.css('display','none');
		this.boxJQ = jQuery('<div />').addClass('fotoEditor');
		this.fidJQ.parent().append(this.boxJQ);
		this.boxJQ.sortable({
			axis: 'y',
			//start: jQuery.proxy(function( event, ui ) {(ui).css(},this),
			stop: jQuery.proxy(function( event, ui ) {this.setEditorJQ();},this)
		});
		this.fotoJQ=0
		if (typeof(SetUrl) != 'undefined') {
			this.OrigSetUrl = SetUrl;				
			SetUrl = jQuery.proxy(function(url, width, height, alt) {
				var lastfoto = lastImageCtrl;
				this.OrigSetUrl(url, width, height, alt);
				if (jQuery(lastfoto)!=null) jQuery(lastfoto).trigger('change');
			},this)
		}
		for (var f=0;f<hpArrJQ.length;f++) this.addItemJQ(hpArrJQ[f]);
		//this.boxJQ.children('div.fotoitem').css({ cursor:'move' });
		this.boxJQ.find('input').on('mousedown',function(event){event.stopPropagation();});
	},
	brJQ: function(){return jQuery('<br />');},
	spJQ: function(text){return jQuery('<span />').text(text);},
	addItemJQ: function(values,elem){
		this.fotoJQ++;
		var f = this.fotoJQ;
		var rowDivJQ = jQuery('<div />').addClass('fotoitem').css({ cursor:'move' });
		if (elem) {rowDivJQ.insertAfter(elem);} else {this.boxJQ.append(rowDivJQ);}
		if (!values) values=['','',''];
		var imgURLJQ = jQuery('<input />').attr({type:'text', name:'foto_'+this.nameJQ+'_'+f, id:'foto_'+this.nameJQ+'_'+f,class:'imageField_multiphotos', value:values[0]}).on('change', jQuery.proxy(function(){
			var url = imgURLJQ.val();
			{$thumbUrl}
			var imgDivJQ = jQuery('#foto_'+this.nameJQ+'_'+f+'_'+'PrContainer');
			if (imgDivJQ!=null) { imgDivJQ.remove(); }
			if (url != "") {
				var styles = {};
				if($styleBool) {
					styles = {
						"max-width":"{$w}px",
						"max-height":"{$h}px",
						"cursor":"pointer"
					};
				}
				else { styles = {}; }
				jQuery('<div />').attr({class:'fotoimg', id:'foto_'+this.nameJQ+'_'+f+'_'+'PrContainer' }).width('{$w}px').prependTo(rowDivJQ).append(
					jQuery('<img />').attr({src:url, class:'foto_img_mf'}).css( styles ).on('click', jQuery.proxy(function(){ BrowseServer('foto_'+this.nameJQ+'_'+f) },this))
				);
			}
			this.setEditorJQ();
		},this));
		var bInsertJQ = jQuery('<input />').attr({type:'button', value:'{$lang['insert']}'}).on('click', jQuery.proxy(function(){
			BrowseServer('foto_'+this.nameJQ+'_'+f);
		},this));
		var linkURLJQ = jQuery('<input />').attr({type:'text', name:'link_'+this.nameJQ+'_'+f, id:'link_'+this.nameJQ+'_'+f, class:'imageField_multiphotos', value:values[1]}).on('change', jQuery.proxy(function(){
			this.setEditorJQ();
		},this));
		var bInsertLinkJQ = jQuery('<input />').attr({type:'button', value:'{$lang['insert']}'}).on('click', jQuery.proxy(function(){
			BrowseServer('link_'+this.nameJQ+'_'+f);
		},this));
		var imgNameJQ = jQuery('<input />').attr({type:'text', class:'imageField_multiphotos', value:values[2]}).on('keyup', jQuery.proxy(function(){ this.setEditorJQ(); documentDirty=true; },this));
		var bAddJQ = jQuery('<input />').attr({type:'button',value:'+', class:'multifotos_add'}).on('click', jQuery.proxy(function() {
			this.addItemJQ(null,rowDivJQ);
		},this));
		rowDivJQ.append(this.spJQ('{$lang['url']}'),this.brJQ(),imgURLJQ,bInsertJQ,this.brJQ(),this.spJQ('{$lang['link']}'),this.brJQ(),linkURLJQ,bInsertLinkJQ,this.brJQ());
		rowDivJQ.append(this.spJQ('{$lang['title']}'),this.brJQ(),imgNameJQ,bAddJQ);
		//if (this.boxJQ.children('div.fotoitem').length>1) {
			rowDivJQ.append(jQuery('<input />').attr({type:'button',value:'-'}).on('click', jQuery.proxy(function(){
				rowDivJQ.remove();
				this.setEditorJQ();
			},this)));
		//}
		imgURLJQ.trigger('change');
	},
	setEditorJQ: function(){
		var hpArrJQ = new Array();
		var divfotoitemJQ = this.boxJQ.children('div.fotoitem');
		divfotoitemJQ.each(function(i,elem){
			var itemsArr = new Array();
			var inputs = jQuery(this).children('input[type=text]');
			var noempty = false;
			inputs.each(function(i2,elem2){itemsArr.push(jQuery(this).val()); if(jQuery(this).val()) noempty=true;});
			if (noempty) hpArrJQ.push(itemsArr);
		});
		this.fidJQ.val((hpArrJQ.length>0) ? Json.toString(hpArrJQ) : '');
		//console.log(Json.toString(hpArrJQ));
	}
});
window.addEvent('domready', function(){
	var tvIds = [$tvIds];
	for (var i=0;i<tvIds.length;i++){
		var fid = 'tv'+ tvIds[i];
		if(jQuery('#'+fid)!=null) {var modxMultiPhotos = new MultiPhotos(fid);}
	}
});
</script>
<!-- /MultiPhotos -->
OUT;
$e->output($output);
}
if ($e->name == 'OnBeforeDocFormSave'){
$tvIds=explode(',',$tvIds);
foreach ($tvIds as $tvid) {
	if (empty($th_width) && empty($th_height)) return;
	if (!$resize || !isset($tmplvars[$tvid]) || empty($tmplvars[$tvid][1])) continue;
	$fotoArr=json_decode($tmplvars[$tvid][1]);
	@set_time_limit(0);
	foreach ($fotoArr as $k=>&$v) {
		if (!empty($v[1]) && $auto_small) $v[0]=$v[1];
		if (!empty($v[0])){
			$filename = basename($v[0]);
			$dirname = str_replace($filename,'',$v[0]);
			if (!($auto_small && !empty($v[1])) && ($prefix==substr($filename, 0, strlen($prefix)) || $prefix==substr($dirname, -strlen($prefix)))) continue;
			$new_path = '../'.$dirname.$prefix.$filename;
			$imgInfo = @getImageSize('../'.$v[0]);
			if (!is_array($imgInfo)) continue;
			ob_start();
			$img_width = $imgInfo[0];
			$img_height = $imgInfo[1];
			$width=$img_width;
			$height=$img_height;
			$posX=0;
			$posY=0;	
			$ratio = $img_height / $img_width;
			if (!$th_height) $th_h=round($th_width*$ratio); else $th_h=$th_height;
			if (!$th_width) $th_w=round($th_height/$ratio); else $th_w=$th_width;
			$th_ratio = $th_h / $th_w;
			if ($crop) {
				if ($ratio > $th_ratio) {
					$height=round($img_width*$th_ratio);
					$posY=round(($img_height-$height)/2);
				}
				if ($ratio < $th_ratio) {
					$width=round($img_height/$th_ratio);
					$posX=round(($img_width-$width)/2);
				}
			}
			else {
				if ($ratio > $th_ratio) $th_w=round($th_h/$ratio);
				if ($ratio < $th_ratio) $th_h=round($th_w*$ratio);
			}
			switch($imgInfo[2]){
			case 1:
				$src = ImageCreateFromGif('../'.$v[0]);
				$dst = ImageCreateTrueColor($th_w, $th_h);
				ImageCopyResampled($dst, $src, 0, 0, $posX, $posY, $th_w, $th_h, $width, $height);
				ImageGif($dst,$new_path);
				break;
			case 2:
				$src = ImageCreateFromJpeg('../'.$v[0]);
				$dst = ImageCreateTrueColor($th_w, $th_h);
				ImageCopyResampled($dst, $src, 0, 0, $posX, $posY, $th_w, $th_h, $width, $height);
				ImageJpeg($dst,$new_path,90);
				break;
			case 3:
				$src = ImageCreateFromPng('../'.$v[0]);
				$dst = ImageCreateTrueColor($th_w, $th_h);
				imagesavealpha($dst, true);
				$cc=imagecolorallocatealpha($dst, 255, 255, 255, 127);
				imagefill($dst, 0, 0, $cc); 
				ImageCopyResampled($dst, $src, 0, 0, $posX, $posY, $th_w, $th_h, $width, $height);
				ImagePng($dst,$new_path);
				break;
			}
			imagedestroy($src);
			imagedestroy($dst);
			if (empty($v[1]) && $auto_big) $v[1]=$v[0];
			$v[0]=$dirname.$prefix.$filename;
			ob_end_clean();
		}
	}
	$tmplvars[$tvid][1]=str_replace('\\/', '/', json_encode($fotoArr));
}
}
