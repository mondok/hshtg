# Public: Not particularly proud of these tests
# Basically, we need to write to a file in order
# to find out what trap sequence was called
# because using variables between fork and
# trap was not happening.
# TODO: consider rewriting using thread variables if possible
# HACK: seriously, this is really dirty
RSpec.describe Hshtg, '#signal_integrations' do

  context 'server for signaling' do

    def subprocess(&block)
      if Process.respond_to?(:fork)
        fork { block.call }
      else
        spawn { block.call }
      end
    end

    it 'can quit process with QUIT signal' do
      tmp_file = 'signal.tmp'

      def notify(message)
        File.open('signal.tmp', 'w') { |file| file.write(message) }
      end

      Hshtg::Util::Utils.load_env_vars
      pid = subprocess do
        Hshtg::Http::ServerBootstrapper.subscribe(self)
        Hshtg::Http::ServerBootstrapper.start
      end
      sleep 5
      begin
        Process.kill('QUIT', pid)
        sleep 2
        group_id = Process.getpgid(pid)
        expect(group_id).to be_nil
        content = ''
        File.foreach(tmp_file) { |x| content << x }
        expect(content).to include('QUIT received')
        File.delete(tmp_file)
      rescue Errno::ESRCH
      end
    end

    it 'can quit process with TERM signal' do
      tmp_file = 'signal.tmp'

      def notify(message)
        File.open('signal.tmp', 'w') { |file| file.write(message) }
      end

      Hshtg::Util::Utils.load_env_vars
      pid = subprocess do
        Hshtg::Http::ServerBootstrapper.subscribe(self)
        Hshtg::Http::ServerBootstrapper.start
      end
      sleep 5
      begin
        Process.kill('TERM', pid)
        sleep 2
        group_id = Process.getpgid(pid)
        expect(group_id).to be_nil
        content = ''
        File.foreach(tmp_file) { |x| content << x }
        expect(content).to include('TERM received')
        File.delete(tmp_file)
      rescue Errno::ESRCH
      end
    end

    it 'can quit process with INT signal' do
      tmp_file = 'signal.tmp'

      def notify(message)
        File.open('signal.tmp', 'w') { |file| file.write(message) }
      end

      Hshtg::Util::Utils.load_env_vars
      pid = subprocess do
        Hshtg::Http::ServerBootstrapper.subscribe(self)
        Hshtg::Http::ServerBootstrapper.start
      end
      sleep 5
      begin
        Process.kill('INT', pid)
        sleep 2
        group_id = Process.getpgid(pid)
        expect(group_id).to be_nil
        content = ''
        File.foreach(tmp_file) { |x| content << x }
        expect(content).to include('INT received')
        File.delete(tmp_file)
      rescue Errno::ESRCH
      end
    end

    it 'can restart process with HUP signal' do
      tmp_file = 'signal.tmp'

      def notify(message)
        File.open('signal.tmp', 'w') { |file| file.write(message) }
      end

      Hshtg::Util::Utils.load_env_vars
      pid = subprocess do
        Hshtg::Http::ServerBootstrapper.subscribe(self)
        Hshtg::Http::ServerBootstrapper.start
      end
      sleep 5
      begin
        Process.kill('HUP', pid)
        sleep 2
        content = ''
        File.foreach(tmp_file) { |x| content << x }
        expect(content).to include('HUP received')
        Process.kill('INT', pid)
        File.delete(tmp_file)
      rescue Errno::ESRCH
      end
    end
  end
end
