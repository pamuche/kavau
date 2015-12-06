class CreditAgreementPresenter < BasePresenter
  def amount
    h.number_to_currency(@model.amount)
  end

  def interest_rate
    h.number_to_percentage(@model.interest_rate)
  end

  def cancellation_period
    h.t('months', count: @model.cancellation_period)
  end

  def confirmation_label
    [
      I18n.t('confirmation_label.credit_agreement'),
      'Nr.', id,
      I18n.t("confirmation_label.of.#{@model.creditor.type.underscore}"),
      [@model.creditor.first_name, @model.creditor.name].compact.join(' '),
    ].join(' ')
  end

  def balance_items
    (reload.payments + balances_and_interests).sort_by(&:date)
  end

  def balances_and_interests
    (balances + (termination_balance ? [] : [todays_balance])).map{ |bal|
      [bal.interest_spans, bal]
    }.flatten
  end

  def todays_total
    h.number_to_currency(@model.todays_total)
  end

end
