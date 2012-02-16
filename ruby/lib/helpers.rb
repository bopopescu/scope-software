module USBScope
  def bit(d,n)
    (d & 1 << n) >> n
  end
end
