class UserWithEmailFormFixture < ActionForm::Base
  self.main_model = :user
  attribute :name,   required: true
  attribute :age,    required: true
  attribute :gender, required: true

  association :email do
    attribute :address, required: true

    validates :address, length: { in: 6..18 }
    validate  :foo_bar

    def foo_bar
      errors.add(:address, :invalid) if address == 'petrakos1@gmail.com'
    end
  end

  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }
  validate  :bar_foo

  def bar_foo
    errors.add(:name, :invalid) if name == 'Petrakos1'
  end
end
