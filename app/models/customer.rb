class Customer < ApplicationRecord
  has_many :rentals
  
  def self.group_by_n(sort_type, n, page)
    if sort_type
      customers = Customer.sort_by_type(sort_type).to_a
    else
      customers = Customer.all.to_a
    end
    
    if n
      iterations = (customers.count)/n.to_i
      
      groups_of_customers = []

      # separates customers into page groups based on n
      iterations.times do
        groups_of_customers << customers.shift(n.to_i)
      end
      
      groups_of_customers << customers unless customers.empty?  

      # selects array to be displayed to user
      if page
        groups_of_customers = groups_of_customers[page.to_i - 1]
      end
      
      return groups_of_customers
    else 
      return customers
    end
  end
  
  def self.sort_by_type(sort_type)
    sort_type = sort_type.to_sym
    return Customer.order(sort_type => :asc)
  end
end
