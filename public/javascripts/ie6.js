/*IE6下的特定处理*/
jQuery(function($) {
	$('.table tbody').hover(function() {
		$(this).css({
			cursor: 'pointer'
		});
	});
});

