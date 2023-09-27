{
  :en => {
    :date => {
      :formats => {
        :medium => lambda { |date, _| "%B #{date.day.ordinalize}" }
      }
    }
  }
}