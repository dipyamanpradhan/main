class Api::EmployeesController < Api::ApplicationController
	before_action :set_employee, only: [:show]

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      render json: @employee, status: :created
    else
      render json: @employee.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @employee
  end
  def tax_deduction
    @employee = Employee.find(params[:id])
    total_salary = calculate_total_salary(@employee)
    tax_amount = calculate_tax(total_salary)
    cess_amount = calculate_cess(total_salary)

    render json: {
      employee_code: @employee.id,
      first_name: @employee.first_name,
      last_name: @employee.last_name,
      yearly_salary: total_salary,
      tax_amount: tax_amount,
      cess_amount: cess_amount
    }
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:employee_id, :first_name, :last_name, :email, :phone_numbers, :doj, :salary)
  end
  def calculate_total_salary(employee)
  	doj = Employee.find(params[:id]).doj
  	salary = Employee.find(params[:id]).salary
  	loss_of_pay_per_day = salary/30
    total_months = (Date.today.year * 12 + Date.today.month) - (doj.year * 12 + doj.month) + 1
    total_salary = (salary - (doj.day - 1) * loss_of_pay_per_day) * total_months
  end

  def calculate_tax(salary)
    case salary
	  when 0..250000
	    0
	  when 250001..500000
	    (salary - 250000) * 0.05
	  when 500001..1000000
	    250000 * 0.05 + (salary - 500000) * 0.10
	  else
	    250000 * 0.05 + 500000 * 0.10 + (salary - 1000000) * 0.20
	  end
  end

  def calculate_cess(salary)
    excess_amount = [salary - 2500000, 0].max
	  cess_rate = 0.02
	  cess_amount = excess_amount * cess_rate
	  cess_amount
  end
end
