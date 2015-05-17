defmodule Ssherminator do
  require Logger

  def go do
    ips = for port <- 10001..15000 do
      {{127,0,0,1}, port}
    end
    devs = start_devices(ips)
    spawn(__MODULE__, :exec_cmds, [devs])
  end

  def start_devices(ips) do
    devices = for {ip, port} <- ips do
      res = start_ssh_server(ip, port)
      {res, port}
    end
    ok = devices |> Enum.filter(
      fn({{:error,_}, _port}) -> false
        (_) -> true
      end)
    Logger.info "#{length ok} devices ok"
    ok
  end

  def start_ssh_server(ip, port) do
    res = :ssh.daemon(ip, port,
                      [system_dir: './priv/server/',
                       user_dir: './priv/client/.ssh/'])
    case res do
      {:ok, ssh_ref} -> ssh_ref;
      {:error, reason} -> {:error, reason}
    end
  end

  def exec_cmds(devs) do
    for {_,port} <- devs do
      spawn(__MODULE__, :exec_cmd, [self(), 'ls', 'localhost', port])
    end

    Logger.info("Waiting for #{length(devs)} devices to report back")
    {microsecs, :done} = :timer.tc(__MODULE__, :receive_msgs, [length(devs)])
    Logger.info("Received results in: #{inspect (microsecs/1000000)}")
  end

  def exec_cmd(controller_pid, cmd, host, port) do
    {:ok, conn_ref} =
      :ssh.connect(host, port, [user_dir: './priv/client/.ssh',
                                silently_accept_hosts: true])
    {:ok, chan_id} = :ssh_connection.session_channel(conn_ref, :infinity)
    :success = :ssh_connection.exec(conn_ref, chan_id, cmd, :infinity)
    :ssh.close(conn_ref)
    send(controller_pid, :ok)
  end

  def receive_msgs(0), do: :done
  def receive_msgs(n) do
    receive do
      :ok -> receive_msgs(n-1)
    end
  end
end
