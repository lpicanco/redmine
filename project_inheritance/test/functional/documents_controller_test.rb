# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.dirname(__FILE__) + '/../test_helper'
require 'documents_controller'

# Re-raise errors caught by the controller.
class DocumentsController; def rescue_action(e) raise e end; end

class DocumentsControllerTest < Test::Unit::TestCase
  fixtures :projects, :users, :roles, :members, :enabled_modules, :documents, :enumerations
  
  def setup
    @controller = DocumentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_index
    get :index, :project_id => 'ecookbook'
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:grouped)
  end
  
  def test_new_with_one_attachment
    @request.session[:user_id] = 2
    post :new, :project_id => 'ecookbook',
               :document => { :title => 'DocumentsControllerTest#test_post_new',
                              :description => 'This is a new document',
                              :category_id => 2},
               :attachments => [ ActionController::TestUploadedFile.new(Test::Unit::TestCase.fixture_path + '/files/testfile.txt', 'text/plain') ]
               
    assert_redirected_to 'projects/ecookbook/documents'
    
    document = Document.find_by_title('DocumentsControllerTest#test_post_new')
    assert_not_nil document
    assert_equal Enumeration.find(2), document.category
    assert_equal 1, document.attachments.size
    assert_equal 'testfile.txt', document.attachments.first.filename
  end
  
  def test_destroy
    @request.session[:user_id] = 2
    post :destroy, :id => 1
    assert_redirected_to 'projects/ecookbook/documents'
    assert_nil Document.find_by_id(1)
  end
end