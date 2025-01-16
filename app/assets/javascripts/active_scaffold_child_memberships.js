jQuery(document).ready(function () {
  jQuery(document).on('click', '.child_memberships table caption a', function(e) {
    e.preventDefault();
    var link = jQuery(e.target), table = link.closest('table'), header = table.find('thead tr'),
      checkbox = jQuery('<input type="checkbox" value="' + (header.find('th').length - 1) + '"/>'), th;
    th = jQuery('<th>').html(link.parent().find('.as_inplace_pattern:first').html()).find('[disabled]').prop('disabled', false).end();
    header.append(th);
    table.find('tbody tr').each(function(){
      var row = jQuery(this);
      row.append(jQuery('<td>').html(checkbox.attr('name', table.data('name')+'[memberships]['+row.data('id')+'][]').clone()));
    });
    th.trigger('as:element_created');
  });
});