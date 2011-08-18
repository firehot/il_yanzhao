jQuery(function($) {
	var enter2tab = function(e) {
		if (e.keyCode == 13) {

			/* FOCUS ELEMENT */
			var inputs = $(this).parents("form,.enter2tab").eq(0).find('input:visible,select:visible,textarea:visible');
			var idx = inputs.index(this);

			if (idx == inputs.length - 1) {
				//自动跳到保存按钮上
				$(inputs[idx]).change();
				$('.btn_save:first').focus();
			} else {
				$(inputs).css({
					backgroundColor: '#fff'
				});
				$(inputs).filter(function() {
					return $(this).attr('readonly')
				}).css({
					backgroundColor: '#EDEDED'
				});
				$(inputs[idx + 1]).css({
					backgroundColor: '#68B4EF'
				});

				$(inputs[idx]).change(); //  handles submit buttons
				inputs[idx + 1].focus(); //  handles submit buttons
				var tag_name = $(inputs[idx + 1]).attr('tagName').toLowerCase();
				if (tag_name == 'input' || tag_name == 'textarea') inputs[idx + 1].select();
			}
			return false;
		}

	};
	$('form input:visible,form select:visible,form textarea:visible').livequery("keypress", enter2tab);
	$('.enter2tab input:visible,.enter2tab select:visible,.enter2tab textarea:visible').livequery("keypress", enter2tab);
});

