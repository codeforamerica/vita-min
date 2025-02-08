{
  :en => {
    :date => {
      :formats => {
        :medium => ->(date, _) { "%B #{date.day.ordinalize}" }
      }
    }
  }
}
