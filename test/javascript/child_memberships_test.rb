# frozen_string_literal: true

require 'javascript_test_helper'

class ChildMembershipsJavascriptTest < ActiveScaffold::TestSupport::Javascript::TestCase
  def fixture_html
    <<~HTML
      <script>
        jQuery(document).on('as:element_created', function() {
          window.membershipHeaderCreated = true;
        });
      </script>
      <div class="active-scaffold child_memberships">
        <table data-name="record[children]">
          <caption>
            <span><a id="add-membership" href="#">Add</a><span class="as_inplace_pattern"><input disabled value="name"></span></span>
          </caption>
          <thead><tr><th>Name</th></tr></thead>
          <tbody>
            <tr data-id="11"><td>First</td></tr>
            <tr data-id="22"><td>Second</td></tr>
          </tbody>
        </table>
      </div>
    HTML
  end

  def test_adds_membership_column_and_row_checkboxes
    visit_javascript_fixture
    click_link 'Add'

    assert_selector 'thead th', count: 2
    assert_selector 'thead th input:not([disabled])'
    assert_selector 'tbody tr[data-id="11"] input[name="record[children][memberships][11][]"]'
    assert_selector 'tbody tr[data-id="22"] input[name="record[children][memberships][22][]"]'
    assert_javascript 'window.membershipHeaderCreated === true'
    assert_no_javascript_errors
  end
end
