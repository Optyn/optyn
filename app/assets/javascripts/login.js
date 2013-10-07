$(document).ready(function () {
    var login = new Login();
    login.initialize();
});

function Login() {
    var current = this;
    var linkHref = null;

    this.initialize = function () {
        if ($('.login-container').length) {
            //this.hookSocialMediaRedirection();
        }

        if($('#login_type_modal').length){
            //this.hookLoginTypeSelection();
        }
    };

    this.hookSocialMediaRedirection = function () {
        $('body').on('click', '.login-container .social a', function (event) {
            event.preventDefault();
            linkHref = $(this).prop('href');
            $('#login_type_modal').modal('show');
        });
    };

    this.hookLoginTypeSelection = function () {
        // The code on modal button click will go here.
        $('body').on('click', '#login_type_modal .login-type-action', function (event) {
            event.preventDefault();
            $('#login_type').val($(this).attr('href').replace("#", ''));
            current.isLoginTypeSet();
        });
    };

    this.isLoginTypeSet = function () {
        var isTypeSet = true
        
        $.ajax({
            url: $('#login_type_omniauth_clients_path').val(),
            type: 'GET',
            data: {user_type: $('#login_type').val()},
            beforeSend: function(){
                $('#login_type_modal .actions-wrapper').hide();
                $('#login_type_modal #loading').show();
            },
            success: function (data) {
                $('#login_type_modal #loading').hide();
                $('#login_type_modal .actions-wrapper').show();
                $('#login_type_modal').modal('hide');
                setTimeout(function(){
                    window.location = linkHref;
                }, 100)

            },
            error: function (data) {
                alert('Sorry an error has occurred. Please refresh your page and try logging in again.');
                isTypeSet = false;
            }
        });

        return isTypeSet;
    };
}