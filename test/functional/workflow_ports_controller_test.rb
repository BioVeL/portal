require 'test_helper'

class WorkflowPortsControllerTest < ActionController::TestCase
  setup do
    @workflow_port = workflow_ports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflow_ports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workflow_port" do
    assert_difference('WorkflowPort.count') do
      post :create, workflow_port: { display_control_id: @workflow_port.display_control_id, display_description: @workflow_port.display_description, display_name: @workflow_port.display_name, name: @workflow_port.name, order: @workflow_port.order, port_value_type: @workflow_port.port_value_type, sample_file: @workflow_port.sample_file, sample_value: @workflow_port.sample_value, show: @workflow_port.show, workflow_id: @workflow_port.workflow_id }
    end

    assert_redirected_to workflow_port_path(assigns(:workflow_port))
  end

  test "should show workflow_port" do
    get :show, id: @workflow_port
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @workflow_port
    assert_response :success
  end

  test "should update workflow_port" do
    put :update, id: @workflow_port, workflow_port: { display_control_id: @workflow_port.display_control_id, display_description: @workflow_port.display_description, display_name: @workflow_port.display_name, name: @workflow_port.name, order: @workflow_port.order, port_value_type: @workflow_port.port_value_type, sample_file: @workflow_port.sample_file, sample_value: @workflow_port.sample_value, show: @workflow_port.show, workflow_id: @workflow_port.workflow_id }
    assert_redirected_to workflow_port_path(assigns(:workflow_port))
  end

  test "should destroy workflow_port" do
    assert_difference('WorkflowPort.count', -1) do
      delete :destroy, id: @workflow_port
    end

    assert_redirected_to workflow_ports_path
  end
end
