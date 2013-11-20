$(document).ready(function () {
    var myConsumerDetail = new MyConsumerDetail();
    myConsumerDetail.initialize();

    // Hook the jquery exander.
    $('div#merchants span.expandable').expander({
    slicePoint:       50,  // default is 100
    expandPrefix:     ' ', // default is '... '
    expandText:       '[...]', // default is 'read more'
    userCollapseText: '[^]'  // default is 'read less'
  });
});


function MyConsumerDetail() {
    this.initialize = function () {
        if ($('#conusmer_connection_modal').length) {
            this.hookOpenConnectionModal();
            if($('#user_label_list .chzn-select').length > 0){
              $('div.labels div.chzn-container').width(500);
            }

            this.hookModalBehavior();
             $('#conusmer_connection_modal').on('hidden', function () {
              $('#conusmer_connection_modal').html('Please Wait...');                          
            });

             $('#conusmer_connection_modal').modal({
              keyboard: false,
              show: false
            });
        }
        if ($('#add_user .chzn-select').length) {
          this.hookChosen();
          this.hookCreateLabelOnly();
        }
    };


    this.hookModalBehavior = function(){
      this.hookChosen();
      this.hookAddNewLabel();
      this.hookChangeChosen();
      this.hookEditUserLink();
      this.hookUpdateUserLink();

    };  

    this.hookOpenConnectionModal = function(){
        var consumerInstance = this;
        $('.consumer_connection_link').on('click', function(){

          var $link = $(this);
          //load the modal content
          $('#conusmer_connection_modal').modal('show')
          $('#conusmer_connection_modal').on('shown', function () {
            $.get($link.next('input[type="hidden"]').val(), function(data){
              //Replace the html
              $('#conusmer_connection_modal').html(data);
              
              //Hook the chosen behavior
              consumerInstance.hookModalBehavior();
            });
           
            $('#conusmer_connection_modal').unbind('shown');
          });
        });
    };

    this.hookEditUserLink = function(){
      var consumerInstance = this;
      $('.consumer_edit_link').on('click', function(){
        var $link = $(this);
        $('#conusmer_connection_modal').html('Please Wait...');
        
        $.get($link.next('input[type="hidden"]').val(), function(data){
          $('#conusmer_connection_modal').html(data);

          //Hook the chosen behavior
          consumerInstance.hookModalBehavior();
        });

      });
    };

    this.hookUpdateUserLink = function(){
      var consumerInstance = this;
      $('.consumer_update_link').on('click', function(){
        var $link = $(this);
        selected_name = $("#user_name").val()
        selected_email = $("#user_email").val()
        
        $('#conusmer_connection_modal').html('Please Wait...');
        $.post($link.next('input[type="hidden"]').val(), {name: selected_name, email: selected_email}, function(data ) {
          $('#conusmer_connection_modal').html(data);

          //Hook the chosen behavior
          consumerInstance.hookModalBehavior();

          setTimeout(function(){
            $('#conusmer_connection_modal').modal('hide');
          }, 1000);
        });
      }); 
    };

    this.hookChosen = function () {
        $('.chzn-select').chosen();
    };

    this.hookAddNewLabel = function () {
        $('body').on('keydown', '#user_label_list .search-field input', function (e) {
            var $input = $(this);
            var code = e.keycode || e.which;
            if (code == 13) {
                var inputVal = $input.val();
                if (inputVal.length) {
                    var $currentLabel = $input.parents('.labels').first();
                    var $currentSelect = $currentLabel.find('select');

                    $.ajax({
                        url: $('#create_label_merchants_survey_survey_answers_path').val(),
                        type: 'POST',
                        data: {label: inputVal, user_id: $currentLabel.find('.user_id').val()},
                        success: function (data) {
                            $('.chzn-select').append(
                                $('<option></option>')
                                    .val(data.id)
                                    .html(data.name)
                            );
                            $currentSelect.find('option[value="' + data.id + '"]').attr('selected', 'selected');
                            $('.chzn-select').trigger("liszt:updated");
                            $('#label_success').text("Label created successfully")
                            $('#label_success').show()
                        }
                    });
                }
            }
        });
    };

    this.hookChangeChosen = function () {
        $('#user_label_list .chzn-select').chosen().change(function(){
            var $select = $(this);

            $.ajax({
              url: $('#update_labels_merchants_survey_survey_answers_path').val(),
              type: 'POST',
              data: {user_id: $select.parent().find('.user_id').val(), label_ids: $select.val()},
              success: function (data) {
                $('#label_success').text("Label updated successfully")
                $('#label_success').show()
              }
            });
        });
    };

    this.hookCreateLabelOnly = function () {
      $('body').on('keydown', '#add_user .search-field input', function (e) {
        var $input = $(this);
        var code = e.keycode || e.which;
        if (code == 13) {
          var inputVal = $input.val();
          if (inputVal.length) {
            var $currentLabel = $input.parents('.labels').first();
            var $currentSelect = $currentLabel.find('select');
            $.ajax({
              url: $('#create_label_users_path').val(),
              type: 'POST',
              data: {label: inputVal},
              success: function (data) {
                $('.chzn-select').append(
                  $('<option></option>').val(data.id).html(data.name)
                );
                $currentSelect.find('option[value="' + data.id + '"]').attr('selected', 'selected');
                $('.chzn-select').trigger("liszt:updated");
                $('#label_success').text("Label created successfully");
                $('#label_success').show();
              }
            });
          }
        }
      });
  };
}