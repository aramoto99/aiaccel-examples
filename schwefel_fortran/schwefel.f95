program schwefel

implicit none

real(kind=8) :: x, y, result
character(len=10) :: arg1, arg2

! プログラム引数から変数値を取得
call get_command_argument(1, arg1)
call get_command_argument(2, arg2)

! 文字列を実数に変換
read(arg1, *) x
read(arg2, *) y

! Schwefel関数の計算
result = 418.9829d0 - x * sin(sqrt(abs(x))) - y * sin(sqrt(abs(y)))

write(*,*) result
end program schwefel
