$(function() {
  $('#js-user-add').on('click', function() {
    $('#js-user-add-modal').modal('show');
  });

  $('#js-user-add-modal').modal('setting', {
    onHide: function() {
      location.reload();
    },
    onApprove: function() {
      var n, s;
      n = $('#name').val();
      e = $('#email').val();
      c = $('#comment').val();
      $.post('/users/', {
        'user[name]': n,
        'user[email]': e,
        'user[comment]': c
      }).done(function(r) {
        if (r.is_success == 1) {
          return $('#js-user-add-modal').modal('hide');
        }
        alert('入力が間違っています');
      });
      return false;
    }
  });
});
