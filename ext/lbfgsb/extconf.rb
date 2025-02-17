require 'mkmf'
require 'numo/narray'

$defs << '-DUSE_INT64' if with_config('use-int64', false)

$LOAD_PATH.each do |lp|
  if File.exist?(File.join(lp, 'numo/numo/narray.h'))
    $INCFLAGS = "-I#{lp}/numo #{$INCFLAGS}"
    break
  end
end

unless have_header('numo/narray.h')
  puts 'numo/narray.h not found.'
  exit(1)
end

if RUBY_PLATFORM =~ /mswin|cygwin|mingw/
  $LOAD_PATH.each do |lp|
    if File.exist?(File.join(lp, 'numo/libnarray.a'))
      $LDFLAGS = "-L#{lp}/numo #{$LDFLAGS}"
      break
    end
  end
  unless have_library('narray', 'nary_new')
    puts 'libnarray.a not found.'
    exit(1)
  end
end

$srcs = Dir.glob("#{$srcdir}/**/*.c").map { |path| File.basename(path) }

blas_dir = with_config('blas-dir')
$LDFLAGS = "-L#{blas_dir} #{$LDFLAGS}" unless blas_dir.nil?

blas_lib = with_config('blas-lib')
unless blas_lib.nil?
  abort "#{blas_lib} not found." unless have_library(blas_lib)
  $srcs.delete('blas.c')
end

$VPATH << "$(srcdir)/src"

create_makefile('lbfgsb/lbfgsbext')
