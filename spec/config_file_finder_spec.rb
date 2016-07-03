require 'spec_helper'

describe ConfigFileFinder do
  let(:config_file_finder) { ConfigFileFinder.new(config_file_name, options) }

  let(:config_file_name) { '.config.yml' }
  let(:options) { {} }

  let(:user_root) { '/users/me' }

  describe 'find' do
    subject { config_file_finder.find }

    before do
      allow(Dir).to receive(:home).and_return(user_root)
    end

    context 'when working dir is root of the project' do
      let(:project_root) { '/users/me/project/root' }

      before do
        allow(Dir).to receive(:pwd).and_return(project_root)
      end

      context 'when config file is present' do
        before do
          allow(File).to receive(:exist?).and_return(false)
          allow(File).to receive(:exist?).with('/users/me/project/root/.git').and_return(true)
          allow(File).to receive(:exist?).with('/users/me/project/root/.config.yml').and_return(true)
        end

        it 'finds the config file' do
          expect(subject[:files].first[:project_root_config]).to eq '/users/me/project/root/.config.yml'
        end
      end

      context 'when no config file exists' do
        context 'when no project root patterns are found' do
          before do
            allow(Dir).to receive(:home).and_return(user_root)
            allow(File).to receive(:exist?).and_return(false)
          end

          it 'stops traversing at the user root' do
            expect(subject[:files]).to include(user_root: '/users/me')
          end

          it 'exists with an failure message about not finding the project root' do
            expect(subject[:message]).to eq "Couldn't find config file .config.yml, "\
                                            'stopping search at user root directory'
          end

          it 'exists with a failed result' do
            expect(subject[:result]).to eq :failed
          end
        end

        context 'when project root directory is found' do
          before do
            allow(File).to receive(:exist?).and_return(false)
            allow(File).to receive(:exist?).with('/users/me/project/root/.git').and_return(true)
          end

          it 'stops traversing at the project root' do
            expect(subject[:files]).to include(project_root: '/users/me/project/root')
          end

          it 'exists with an error message about no finding the config file .config.yml' do
            expect(subject[:message]).to eq "Couldn't find config file .config.yml, "\
                                            'stopping search at project root directory'
          end

          it 'exists with a failed result' do
            expect(subject[:result]).to eq :failed
          end
        end
      end
    end

    context 'when working dir is in a child dir of the project root' do
      let(:project_root_child) { '/users/me/project/root/child' }

      before do
        allow(Dir).to receive(:pwd).and_return(project_root_child)
      end

      context 'when config file exists at the project root' do
        before do
          allow(File).to receive(:exist?).and_return(false)
          allow(File).to receive(:exist?).with('/users/me/project/root/.git').and_return(true)
          allow(File).to receive(:exist?).with('/users/me/project/root/.config.yml').and_return(true)
        end

        it 'finds the config file' do
          expect(subject[:files].first[:project_root_config]).to eq '/users/me/project/root/.config.yml'
        end
      end

      context 'when no config file exists' do
        context 'when no project root patterns are found' do
          it 'stops traversing at the user root' do
            expect(subject[:files]).to include(user_root: '/users/me')
          end

          it 'exists with an failure message about not finding the project root' do
            expect(subject[:message]).to eq "Couldn't find config file .config.yml, "\
                                            'stopping search at user root directory'
          end

          it 'exists with a failed result' do
            expect(subject[:result]).to eq :failed
          end
        end

        context 'when project root directory is found' do
          before do
            allow(File).to receive(:exist?).and_return(false)
            allow(File).to receive(:exist?).with('/users/me/project/root/.git').and_return(true)
          end

          it 'stops traversing at the project root' do
            expect(subject[:files]).to include(project_root: '/users/me/project/root')
          end

          it 'exists with an error message about no finding the config file .config.yml' do
            expect(subject[:message]).to eq "Couldn't find config file .config.yml, "\
                                            'stopping search at project root directory'
          end

          it 'exists with a failed result' do
            expect(subject[:result]).to eq :failed
          end
        end
      end
    end
  end

  describe 'add_root_pattern' do
    subject { config_file_finder.find }

    let(:config_file_finder) { ConfigFileFinder.new(config_file_name, options) }
    let(:project_root_child) { '/users/me/project/root/child' }

    before { allow(Dir).to receive(:pwd).and_return(project_root_child) }

    context 'when adding a single pattern' do
      context 'when working dir is in a child dir of the project root' do
        before { config_file_finder.add_root_patterns '.foo' }

        context 'when config file exists at the project root' do
          before do
            allow(File).to receive(:exist?).and_return(false)
            allow(File).to receive(:exist?).with('/users/me/project/root/.foo').and_return(true)
            allow(File).to receive(:exist?).with('/users/me/project/root/.config.yml').and_return(true)
          end

          it 'finds the config file' do
            expect(subject[:files].first[:project_root_config]).to eq '/users/me/project/root/.config.yml'
          end
        end
      end
    end

    context 'when adding an array of patterns' do
      context 'when working dir is in a child dir of the project root' do
        before { config_file_finder.add_root_patterns ['.foo'] }

        context 'when config file exists at the project root' do
          before do
            allow(File).to receive(:exist?).and_return(false)
            allow(File).to receive(:exist?).with('/users/me/project/root/.foo').and_return(true)
            allow(File).to receive(:exist?).with('/users/me/project/root/.config.yml').and_return(true)
          end

          it 'finds the config file' do
            expect(subject[:files].first[:project_root_config]).to eq '/users/me/project/root/.config.yml'
          end
        end
      end
    end
  end
end
