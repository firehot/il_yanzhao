/*IE6下的特定处理*/
jQuery(function($) {
	$('.table tbody tr').live('hover', function() {
		$(this).css({
			backgroundColor: '#FFCCCC',
			cursor: 'pointer'
		});
	},
	function() {
		$(this).css({
			backgroundColor: '#EAFDFF'
		});
		if ($(this).hasClass('odd')) $(this).css({
			backgroundColor: '#FFFFFF'
		});
	});

});

