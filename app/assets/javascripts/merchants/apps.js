$(document).ready(function(){
	var apps = new Apps();
	apps.initialize();
});

function Apps(){
	this.initialize = function(){
		if($('#app_form').length){
			this.hookResetClick();			
		}
	};

	this.hookResetClick = function(){
		$('#app_form #reset_button').click(function(){
				$('#app_form #reset').val('true');	
		});
	};
}